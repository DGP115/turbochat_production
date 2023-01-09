# frozen_string_literal: true

module Turbochat
  # Turbochat::UserStatus is a class that, When the Rails server starts, sets the status of
  # all users to offline.
  class UserStatus < Application
    config.after_initialize do
      connection = ActiveRecord::Base.connection
      if connection.table.exists?('users') && connection.column.exists?('users', 'status')
        User.update_all(status: User.statuses[:offline])
      end
    rescue StandardError
      puts 'NOTICE:  /initializers/user_status.rb:  Failed to initialize user statuses'
    end
  end
end
