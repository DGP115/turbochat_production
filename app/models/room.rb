# frozen_string_literal: true

# Definition of the public and private chatrooms of this app
class Room < ApplicationRecord
  validates_uniqueness_of :name
  scope :public_rooms, -> { where(is_private: false) }
  scope :private_rooms, -> { where(is_private: true) }
  after_update_commit { broadcast_if_public }
  has_many :messages, dependent: :destroy
  has_many :participants, dependent: :destroy

  #  "Joinables" is the association table for the many:many between rooms and users
  has_many :joinables, dependent: :destroy
  #  This statement could have been has_many : users, but to add a little
  #  more detail:
  #    We are naming the association "joined_users" and telling the model that
  #    it is given by going through the joinables model [table] to get to the
  #    "source" user model
  has_many :joined_users, through: :joinables, source: :user

  has_noticed_notifications model_name: 'Notification'

  def broadcast_if_public
    broadcast_latest_message
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

  def latest_message
    messages.includes(:user).order(created_at: :desc).first
  end

  def broadcast_latest_message
    last_message = latest_message

    #  If last_message is nil, return without doing anything
    return unless last_message

    target = "room_#{id} last-message"

    # 'rooms' is the channel.  'target' is the <div>/container of interest,
    # locals: are the local variables
    broadcast_update_to('rooms',
                         target: target,
                         partial: 'rooms/last_message',
                         locals: {
                           room: self,
                           user: last_message.user,
                           last_message: last_message
                         })
  end
end
