action :install do |new_resource|

  service_name = "pgbouncer-#{new_resource['name']}"

  log_file  = new_resource['log_file']  || "/var/log/#{service_name}.log"
  pid_file  = new_resource['pid_file']  || "/tmp/#{service_name}.pid"
  auth_file = new_resource['auth_file'] || "/etc/pgbouncer/userlist-#{new_resource['name']}.txt"

  directory '/etc/pgbouncer'

  template auth_file do
    source 'userlist.txt.erb'
    cookbook 'pgbouncer'
    owner node['pgbouncer']['os_user']
    group node['pgbouncer']['os_group']
    mode 0644
    variables 'users' => new_resource['user_list']
    notifies :reload, "service[#{service_name}]"
  end

  template "/etc/pgbouncer/#{service_name}.ini" do
    source 'pgbouncer.ini.erb'
    cookbook 'pgbouncer'
    owner node['pgbouncer']['os_user']
    group node['pgbouncer']['os_group']
    mode 0644
    variables 'databases'                => new_resource['databases'],
              'log_file'                 => log_file,
              'pid_file'                 => pid_file,
              'listen_address'           => new_resource['listen_address'],
              'listen_port'              => new_resource['listen_port'],
              'unix_socket_dir'          => new_resource['unix_socket_dir'],
              'auth_type'                => new_resource['auth_type'],
              'auth_file'                => auth_file,
              'admin_users'              => new_resource['admin_users'],
              'stats_users'              => new_resource['stats_users'],
              'pool_mode'                => new_resource['pool_mode'],
              'server_reset_query'       => new_resource['server_reset_query'],
              'server_check_query'       => new_resource['server_check_query'],
              'server_check_delay'       => new_resource['server_check_delay'],
              'max_client_conn'          => new_resource['max_client_conn'],
              'default_pool_size'        => new_resource['default_pool_size'],
              'reserve_pool_size'        => new_resource['reserve_pool_size'],
              'min_pool_size'            => new_resource['min_pool_size'],
              'log_connections'          => new_resource['log_connections'],
              'log_disconnections'       => new_resource['log_disconnections'],
              'log_pooler_errors'        => new_resource['log_pooler_errors'],
              'server_lifetime'          => new_resource['server_lifetime'],
              'server_idle_timeout'      => new_resource['server_idle_timeout'],
              'idle_transaction_timeout' => new_resource['idle_transaction_timeout'],
              'server_connect_timeout'   => new_resource['server_connect_timeout'],
              'server_login_retry'       => new_resource['server_login_retry']

    notifies :reload, "service[#{service_name}]"
  end

  file log_file do
    owner node['pgbouncer']['os_user']
    group node['pgbouncer']['os_group']
    mode 0644
    action :create_if_missing
  end

  case node['pgbouncer']['init_method']
    when 'smf'
      resource_control_project service_name do
        comment "PGBouncer instance for #{new_resource['name']}"
        users node['pgbouncer']['os_user']

        process_limits 'max-file-descriptor' => [
          { 'value' => new_resource['max_file_descriptors'], 'level' => 'basic', 'deny' => true },
          { 'value' => new_resource['max_file_descriptors'], 'level' => 'privileged', 'deny' => true }
        ]
      end

      smf service_name do
        project service_name
        start_command "#{node['pgbouncer']['source']['install_dir']}/bin/pgbouncer -d -u #{node['pgbouncer']['os_user']} /etc/pgbouncer/#{service_name}.ini"
        refresh_command ':kill -HUP'
        stop_command ':kill'
        start_timeout 30
        stop_timeout 30
        working_directory '/'

        environment 'LD_LIBRARY_PATH' => '/opt/local/lib'

        notifies :start, "service[#{service_name}]"
      end
  end

  service service_name do
    supports status: true, start: true, stop: true, restart: true, reload: true
  end
end
