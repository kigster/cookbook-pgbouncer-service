require 'digest'

class Chef
  module PgbouncerHelpers
    def pgbouncer_add_user(user, password, admin: false, stats: false)
      the_node.normal['pgbouncer']['userlist'][user] = 'md5' + Digest::MD5.hexdigest(password + user)
      pgbouncer_special_users('admin') << user if admin
      pgbouncer_special_users('stats') << user if stats
    end

    private

    def pgbouncer_special_users(type)
      user_type = "#{type}_users"
      unless the_node['pgbouncer'][user_type].is_a?(Array)
        the_node.normal['pgbouncer'][user_type] = []
      end
      the_node.normal['pgbouncer'][user_type]
    end

    def the_node
      respond_to?(:node) ? node : self
    end
  end

  Node.include(PgbouncerHelpers)
  Recipe.include(PgbouncerHelpers)
  Resource.include(PgbouncerHelpers)
end
