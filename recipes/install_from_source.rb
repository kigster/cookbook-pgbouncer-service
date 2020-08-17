remote_file = node['pgbouncer']['source']['url']
local_file  = remote_file.gsub(%r{.*/}, '') # pgbouncer-1.5.4.tar.gz
local_dir   = local_file.gsub(/\.tar\.gz/, '') # pgbouncer-1.5.4

node.default['pgbounscer']['version'] = local_dir.gsub(/.*-/, '') # 1.5.4

remote_file "#{Chef::Config[:file_cache_path]}/#{local_file}" do
  source remote_file
  mode '744'
  not_if { File.directory?("#{Chef::Config[:file_cache_path]}/#{local_dir}") }
end

package_file = "#{Chef::Config[:file_cache_path]}/#{local_file}"

execute 'extract tar ball into file_cache_path' do
  command "cd #{Chef::Config[:file_cache_path]} && tar -xzvf #{package_file}"
  not_if { File.directory?("#{Chef::Config[:file_cache_path]}/#{local_dir}") }
end

package 'libevent-dev'

execute 'build pgbouncer' do
  command [
            "cd #{Chef::Config[:file_cache_path]}/#{local_dir}",
            "./configure --prefix=#{node['pgbouncer']['source']['install_dir']}",
            'make install',
          ].join(' && ')
  not_if { ::File.exist?("#{node['pgbouncer']['source']['install_dir']}/bin/pgbouncer") }
end
