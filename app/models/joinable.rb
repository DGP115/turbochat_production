# frozen_string_literal: true

#  The many-many association of users and rooms
class Joinable < ApplicationRecord
  belongs_to :user
  belongs_to :room
end
