actions :install
default_action :install

attribute :name, kind_of: String, required: true

attribute :databases, kind_of: Hash, default: {}
attribute :user_list, kind_of: Hash, default: {}
attribute :log_file, kind_of: [String, NilClass], default: nil
attribute :pid_file, kind_of: [String, NilClass], default: nil

attribute :listen_address, kind_of: String, default: '127.0.0.1'
attribute :listen_port, kind_of: Integer, default: 6432
attribute :unix_socket_dir, kind_of: [String, NilClass], default: nil

attribute :auth_type, kind_of: String, default: 'trust', equal_to: %w(any trust plain crypt md5)
attribute :auth_file, kind_of: [String, NilClass], default: nil
attribute :admin_users, kind_of: Array, default: []
attribute :stats_users, kind_of: Array, default: []

attribute :pool_mode, kind_of: String, default: 'transaction', equal_to: %w(session transaction statement)
attribute :server_reset_query, kind_of: String, default: ''
attribute :server_check_query, kind_of: String, default: 'select 1'
attribute :server_check_delay, kind_of: Integer, default: 10

attribute :max_client_conn, kind_of: Integer, default: 100
attribute :default_pool_size, kind_of: Integer, default: 10
attribute :reserve_pool_size, kind_of: [Integer, NilClass], default: nil
attribute :min_pool_size, kind_of: [Integer, NilClass], default: nil

attribute :log_connections, kind_of: [TrueClass, FalseClass], default: true
attribute :log_disconnections, kind_of: [TrueClass, FalseClass], default: true
attribute :log_pooler_errors, kind_of: [TrueClass, FalseClass], default: true

attribute :max_file_descriptors, kind_of: Integer, default: 2000

attribute :server_lifetime, kind_of: Integer, default: 3600
attribute :server_idle_timeout, kind_of: Integer, default: 600
attribute :idle_transaction_timeout, kind_of: Integer, default: nil

attribute :server_connect_timeout, kind_of: Integer, default: 15
attribute :server_login_retry, kind_of: Integer, default: 15
