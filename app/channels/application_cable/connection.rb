# frozen_string_literal: true

# Base for ActionCable
module ApplicationCable
  # Give ActionCable access to the Devise User
  class Connection < ActionCable::Connection::Base
    #  Give ActionCable access to the Devise User
    #  Ref:  https://guides.rubyonrails.org/action_cable_overview.html
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      if (verified_user = env['warden'].user)
        verified_user
      else
        reject_unauthorized_connection
      end
    end
  end
end
