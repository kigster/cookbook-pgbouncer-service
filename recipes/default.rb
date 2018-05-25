include_recipe "pgbouncer-service::install_from_#{node['pgbouncer']['install_method']}"
include_recipe 'pgbouncer-service::configure'
