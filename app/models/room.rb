# frozen_string_literal: true

# Definition of the public and private chatrooms of this app
class Room < ApplicationRecord
  validates_uniqueness_of :name
  scope :public_rooms, -> { where(is_private: false) }
  scope :private_rooms, -> { where(is_private: true) }
  after_create_commit { broadcast_if_public }
  has_many :messages, dependent: :destroy
  has_many :participants, dependent: :destroy

  def broadcast_if_public
    broadcast_append_to 'rooms' unless self.is_private
  end

  def self.create_private_room(users, room_name)
    current_room = Room.create(name: room_name, is_private: true)
    users.each do |user|
      Participant.create(user_id: user.id, room_id: current_room.id)
    end
    current_room
  end

  def participant?(room, user)
    room.participants.where(user: user).exists?
 #   Participant.where(user_id: user_id, room_id: room.id).exists?
  end
end
