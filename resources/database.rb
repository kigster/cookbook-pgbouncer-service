property :database,          String, name_property: true
property :host,              String
property :port,              Integer, default: 5432
property :settings,          String
property :apply_immediately, [true, false], default: false

action :add do
  if new_resource.apply_immediately
    # Set up userlist.txt so that the account can be immediately created
    # This change is temporary as the resource will then edit userlist.txt
    # at a delayed time with all the accounts collected at runtime
    append_if_no_line 'immediately add database entry in /etc/pgbouncer/databases.ini' do
      path '/etc/pgbouncer/databases.ini'
      line pgbouncer_database_line(new_resource.database, new_resource.host, new_resource.port, new_resource.settings)
      sensitive false
      notifies :reload, 'systemd_unit[pgbouncer.service]', :immediately
    end
  end

  with_run_context :root do
    edit_resource(:template, '/etc/pgbouncer/databases.ini') do |new_resource|
      source 'databases.ini.erb'
      cookbook 'pgbouncer-service'
      owner node['pgbouncer']['os_user']
      group node['pgbouncer']['os_group']
      mode '0644'
      variables['databaselines'] ||= []
      variables['databaselines'].push(pgbouncer_database_line(new_resource.database, new_resource.host, new_resource.port, new_resource.settings))
      variables['databaselines'].sort!.uniq!
      action :nothing
      delayed_action :create
      # Only send the notification once
      notifies :reload, 'systemd_unit[pgbouncer.service]' unless run_context.delayed_notification_collection.keys.include?('template[/etc/pgbouncer/databases.ini]')
      # Chef always run notifications even if the current run has failed as part of the converge phase.
      # In this case, this resource is run from a notification triggered by the delayed_action.
      # In order to prevent Chef from running this resource with a halfway filled variables, we need to inhibit it
      # - either if the run has been interrupted (eg CTRL+C), in which case one of the resources execute has no status (nil)
      # - or if any previous resource has failed
      only_if { run_context.action_collection.select { |action_record| action_record.status.nil? || action_record.status == :failed }.count == 0 }
    end
  end
end

action_class do
  def pgbouncer_database_line(database, host, port, settings)
    settings.to_s.split(' ').each do |setting|
      raise "Invalid pgbouncer setting format #{setting}, it should match: key=value" unless setting =~ /^[[:word:]]+[[:blank:]]*=[[:blank:]]*[[:word:]]+$/
    end
    database_line = "#{database} = host=#{host} port=#{port}"
    database_line << " #{settings}" if settings
    database_line
  end
end
