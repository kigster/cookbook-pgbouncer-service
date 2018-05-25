service 'pgbouncer' do
  action :nothing
  supports status: true, start: true, stop: true, restart: true, reload: false
end

case node['platform']
  when 'smartos'

    smf 'pgbouncer' do
      start_command "#{node['pgbouncer']['source']['install_dir']}/bin/pgbouncer -d -u #{node['pgbouncer']['os_user']} /etc/pgbouncer/pgbouncer.ini"
      refresh_command ':kill -HUP'
      stop_command ':kill'
      start_timeout 30
      stop_timeout 30
      working_directory '/'

      environment 'LD_LIBRARY_PATH' => '/opt/local/lib'
    end

  else
    systemd_unit 'pgbouncer.service' do
      content <<-EOF.gsub(/^\s+/, '')
        [Unit]
        Description=PgBouncer
        After=network.target
        
        [Service]
        User=#{node['pgbouncer']['os_user']}
        WorkingDirectory=/home/#{node['pgbouncer']['os_user']}
        ExecStart=#{node['pgbouncer']['source']['install_dir']}/bin/pgbouncer /etc/pgbouncer/pgbouncer.ini
        ExecReload=#{node['pgbouncer']['source']['install_dir']}/bin/pgbouncer -R /etc/pgbouncer/pgbouncer.ini
        Restart=always
        RestartSec=3
        
        [Install]
        WantedBy=multi-user.target
      EOF

      action [:create, :enable]
    end
end


directory '/etc/pgbouncer' do
  owner node['pgbouncer']['os_user']
  mode '0755'
  not_if { File.directory?('/etc/pgbouncer') }
end

template '/etc/pgbouncer/pgbouncer.ini' do
  source 'pgbouncer.ini.erb'
  cookbook 'pgbouncer'
  owner node['pgbouncer']['os_user']
  group node['pgbouncer']['os_group']
  mode '644'
  variables node['pgbouncer']
  notifies :restart, resources(service: 'pgbouncer'), :delayed
end

template '/etc/pgbouncer/userlist.txt' do
  source 'userlist.txt.erb'
  owner node['pgbouncer']['os_user']
  group node['pgbouncer']['os_group']
  mode '644'
  variables 'users' => node['pgbouncer']['userlist']
  notifies :restart, resources(service: 'pgbouncer'), :delayed
end

template '/etc/default/pgbouncer' do
  source 'pgbouncer.default.erb'
  owner node['pgbouncer']['os_user']
  group node['pgbouncer']['os_group']
  mode '644'
  notifies :restart, resources(service: 'pgbouncer'), :delayed
end

[node['pgbouncer']['log_file']].each do |file_name|
  file file_name do
    owner node['pgbouncer']['os_user']
    group node['pgbouncer']['os_group']
    mode '644'
    action :create_if_missing
  end
end


service 'pgbouncer' do
  action [:enable, :start]
end
