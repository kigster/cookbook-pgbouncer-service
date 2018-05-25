case node['platform_family']
when 'smartos'
  default[:pgbouncer][:init_method]          = 'smf'
  default[:pgbouncer][:source][:install_dir] = '/opt/local'
else
  default[:pgbouncer][:init_method]          = 'service'
  default[:pgbouncer][:source][:install_dir] = '/usr/local'
end

default[:pgbouncer][:install_method]          = 'source'
default[:pgbouncer][:source][:url]            = "https://pgbouncer.github.io/downloads/files/1.8.1/pgbouncer-1.8.1.tar.gz"

default[:pgbouncer][:databases] = {}
default[:pgbouncer][:userlist] = {}

default[:pgbouncer][:os_user]  = 'postgres'
default[:pgbouncer][:os_group] = 'postgres'

# Administrative settings
default[:pgbouncer][:log_file] = '/var/log/pgbouncer.log'
default[:pgbouncer][:pid_file] = '/tmp/pgbouncer.pid'

# Where to wait for clients
default[:pgbouncer][:listen_address] = '127.0.0.1'
default[:pgbouncer][:listen_port] = '6432'
default[:pgbouncer][:unix_socket_dir] = nil

# Authentication settings
default[:pgbouncer][:auth_type] = 'trust'
default[:pgbouncer][:auth_file] = '/etc/pgbouncer/userlist.txt'

# Users allowed into database 'pgbouncer'
default[:pgbouncer][:admin_users] = []
default[:pgbouncer][:stats_users] = []

# Pooler personality questions
default[:pgbouncer][:pool_mode] = 'transaction'
default[:pgbouncer][:server_reset_query] = ''
default[:pgbouncer][:server_check_query] = 'select 1'
default[:pgbouncer][:server_check_delay] = '10'

# Connection limits
default[:pgbouncer][:max_client_conn] = '100'
default[:pgbouncer][:default_pool_size] = '10'
default[:pgbouncer][:reserve_pool_size] = nil
default[:pgbouncer][:min_pool_size] = nil
default[:pgbouncer][:log_connections] = true
default[:pgbouncer][:log_disconnections] = true
default[:pgbouncer][:log_pooler_errors] = true
default[:pgbouncer][:server_connect_timeout] = nil
default[:pgbouncer][:server_login_retry] = nil

# Timeouts
default[:pgbouncer][:server_lifetime] = '3600'
default[:pgbouncer][:server_idle_timeout] = '600'
default[:pgbouncer][:idle_transaction_timeout] = nil

# Low-level tuning options
