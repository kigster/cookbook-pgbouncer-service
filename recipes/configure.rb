systemd_unit 'pgbouncer.service' do
  content({
    Unit: {
      Description: 'Connection pooler for PostgreSQL',
      Documentation: 'https://www.pgbouncer.org/',
    },
    Service: {
      # Type notify seems broken for now: https://github.com/pgbouncer/pgbouncer/issues/492
      Type: 'simple',
      User: 'postgres',
      ExecStart: '/usr/sbin/pgbouncer /etc/pgbouncer/pgbouncer.ini',
      ExecReload: '/bin/kill -HUP $MAINPID',
      KillSignal: 'SIGINT',
    },
    Install: {
      WantedBy: 'multi-user.target',
    },
  })
  action [:create, :enable, :start]
end

directory '/etc/pgbouncer' do
  owner node['pgbouncer']['os_user']
  mode '0755'
end

file '/etc/pgbouncer/databases.ini' do
  owner node['pgbouncer']['os_user']
  group node['pgbouncer']['os_group']
  mode '0644'
  action :create_if_missing
end

file '/etc/pgbouncer/users.ini' do
  owner node['pgbouncer']['os_user']
  group node['pgbouncer']['os_group']
  mode '0644'
  action :create_if_missing
end

# Don't restart PgBouncer if not necessary to avoid breaking ongoing connections.
# Execute "SHOW CONFIG" to list the settings that need PgBouncer to be restarted in order to be applied.
# This list needs to be updated if any new attribute is added.
settings_requiring_pgbouncer_restart = %w(listen_addr listen_port unix_socket_dir)
restart_pgbouncer = begin
  ::File.readlines('/etc/pgbouncer/pgbouncer.ini').reject { |line| line.chomp.empty? || line.start_with?(';', '#') || !line.match('=') }
        .map { |line| line.chomp.split(/[[:blank:]]*=[[:blank:]]*/) }
        .reject { |line_setting| line_setting.count != 2 || !settings_requiring_pgbouncer_restart.include?(line_setting[0]) }
        .reduce(false) do |restart, line_setting|
    restart || !!(node['pgbouncer'][line_setting[0]].to_s != line_setting[1] if node['pgbouncer'].key?(line_setting[0]))
  end
                    rescue Errno::ENOENT
                      true
end

template '/etc/pgbouncer/pgbouncer.ini' do
  source 'pgbouncer.ini.erb'
  owner node['pgbouncer']['os_user']
  group node['pgbouncer']['os_group']
  mode '0644'
  variables node['pgbouncer']
  if restart_pgbouncer
    notifies :restart, 'systemd_unit[pgbouncer.service]', :immediately
  else
    notifies :reload, 'systemd_unit[pgbouncer.service]', :immediately
  end
end
