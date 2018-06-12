require 'digest'
class Chef
  module PGBouncerHelper
    def pgbouncer_user(user, password, admin: false, stats: false)
      node.normal['pgbouncer']['userlist'][user] = 'md5' + Digest::MD5.hexdigest(password + user)
      node.normal['pgbouncer']['admin_users'] << user if admin
      node.normal['pgbouncer']['stats_users'] << user if stats
    end
  end

  Recipe.include(PGBouncerHelper)
end



