default['pgbouncer']['source']['install_dir'] = '/usr/local'

default['pgbouncer']['install_method'] = 'source'
default['pgbouncer']['source']['url'] = 'https://www.pgbouncer.org/downloads/files/1.14.0/pgbouncer-1.14.0.tar.gz'

default['pgbouncer']['databases'] = {}
default['pgbouncer']['userlist'] = {}

default['pgbouncer']['os_user']  = 'postgres'
default['pgbouncer']['os_group'] = 'postgres'

# Where to wait for clients
default['pgbouncer']['listen_addr'] = '127.0.0.1'
default['pgbouncer']['listen_port'] = 6432
default['pgbouncer']['unix_socket_dir'] = '/var/run/postgresql'

# Authentication settings
default['pgbouncer']['auth_type'] = 'md5'
default['pgbouncer']['auth_file'] = '/etc/pgbouncer/userlist.txt'

# Users allowed into database 'pgbouncer'
default['pgbouncer']['admin_users'] = []
default['pgbouncer']['stats_users'] = []

# Pooler personality questions
default['pgbouncer']['pool_mode'] = 'transaction'
default['pgbouncer']['server_reset_query'] = 'DISCARD ALL'
default['pgbouncer']['server_check_query'] = 'SELECT 1'
default['pgbouncer']['server_check_delay'] = 30
default['pgbouncer']['ignore_startup_parameters'] = ''

# Connection limits
default['pgbouncer']['max_client_conn'] = 100
default['pgbouncer']['default_pool_size'] = 20
default['pgbouncer']['reserve_pool_size'] = 0
default['pgbouncer']['min_pool_size'] = 0
default['pgbouncer']['log_connections'] = true
default['pgbouncer']['log_disconnections'] = true
default['pgbouncer']['log_pooler_errors'] = true
default['pgbouncer']['server_connect_timeout'] = 15
default['pgbouncer']['server_login_retry'] = 15

# Timeouts
default['pgbouncer']['server_lifetime'] = 3600
default['pgbouncer']['server_idle_timeout'] = 600
default['pgbouncer']['idle_transaction_timeout'] = 0

# Low-level tuning options
