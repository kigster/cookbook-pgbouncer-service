property :user,              String, name_property: true
property :password,          String
property :settings,          String
property :apply_immediately, [true, false], default: false

action :add do
  if new_resource.apply_immediately
    if new_resource.password
      # Set up userlist.txt so that the account can be immediately created
      # This change is temporary as the template resource will then edit userlist.txt
      # at a delayed time with all the accounts collected at runtime
      #
      # Note that there is no need to reload pgbouncer when the userlist.txt is updated
      append_if_no_line 'immediately add user entry in /etc/pgbouncer/userlist.txt' do
        path '/etc/pgbouncer/userlist.txt'
        line pgbouncer_auth_line(new_resource.user, new_resource.password)
        sensitive true
      end
    end

    if new_resource.settings
      append_if_no_line 'immediately add user entry in /etc/pgbouncer/users.ini' do
        path '/etc/pgbouncer/users.ini'
        line pgbouncer_users_line(new_resource.user, new_resource.settings)
        sensitive false
        notifies :reload, 'systemd_unit[pgbouncer.service]', :immediately
      end
    end
  end

  with_run_context :root do
    edit_resource(:template, '/etc/pgbouncer/userlist.txt') do |new_resource|
      source 'userlist.txt.erb'
      cookbook 'pgbouncer-service'
      owner node['pgbouncer']['os_user']
      group node['pgbouncer']['os_group']
      mode '0600'
      sensitive true
      variables['userauthlines'] ||= []
      variables['userauthlines'].push(pgbouncer_auth_line(new_resource.user, new_resource.password)) if new_resource.password
      variables['userauthlines'].sort!.uniq!
      action :nothing
      delayed_action :create
      # Chef always run notifications even if the current run has failed as part of the converge phase.
      # In this case, this resource is run from a notification triggered by the delayed_action.
      # In order to prevent Chef from running this resource with a halfway filled variables, we need to inhibit it
      # - either if the run has been interrupted (eg CTRL+C), in which case one of the resources execute has no status (nil)
      # - or if any previous resource has failed
      only_if { run_context.action_collection.select { |action_record| action_record.status.nil? || action_record.status == :failed }.count == 0 }
    end

    edit_resource(:template, '/etc/pgbouncer/users.ini') do |new_resource|
      source 'users.ini.erb'
      cookbook 'pgbouncer-service'
      owner node['pgbouncer']['os_user']
      group node['pgbouncer']['os_group']
      mode '0644'
      variables['userlines'] ||= []
      variables['userlines'].push(pgbouncer_users_line(new_resource.user, new_resource.settings)) if new_resource.settings
      variables['userlines'].sort!.uniq!
      action :nothing
      delayed_action :create
      # Only send the notification once
      notifies :reload, 'systemd_unit[pgbouncer.service]' unless run_context.delayed_notification_collection.keys.include?('template[/etc/pgbouncer/users.ini]')
      only_if { run_context.action_collection.select { |action_record| action_record.status.nil? || action_record.status == :failed }.count == 0 }
    end
  end
end

action_class do
  def pgbouncer_auth_line(user, password)
    %("#{user}" "md5#{Digest::MD5.hexdigest(password + user)}")
  end

  def pgbouncer_users_line(user, settings)
    settings.to_s.split(' ').each do |setting|
      raise "Invalid pgbouncer setting format #{setting}, it should match: key=value" unless setting =~ /^[[:word:]]+[[:blank:]]*=[[:blank:]]*[[:word:]]+$/
    end
    "#{user} = #{settings}"
  end
end
