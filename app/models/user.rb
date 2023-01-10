# frozen_string_literal: true

# models teh user of this app
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise  :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable

  # This scope statement is a helper that discludes us, the current user, from
  # the list of users to chat with
  scope :all_except, ->(user) { where.not(id: user) }
  after_create_commit { broadcast_append_to 'users' }
  after_update_commit { broadcast_update }
  has_many :messages
  has_one_attached :avatar

  has_many :notifications, as: :recipient, dependent: :destroy

  #  "Joinables" is the association table for the many:many between rooms and users
  has_many :joinables, dependent: :destroy
  #  This statement could have been has_many : rooms, but to add a little
  #  more detail:
  #    We are naming the association "joined_rooms" and telling the model that
  #    it is given by going through the joinables model [table] to get to the
  #    "source" room model
  has_many :joined_rooms, through: :joinables, source: :room

  enum status: %i[offline away online]
  enum role: %i[general admin]

  after_commit :add_default_avatar, on: %i[create update]

  after_initialize :set_default_role, if: :new_record?
  #
  # -------------------------------------------------------------
  # Customization to have Devise use username as login
  attr_writer :login

  validate :validate_username

  def login
    @login || username || email
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    elsif conditions[:username].nil?
      where(conditions).first
    else
      where(username: conditions[:username]).first
    end
  end

  def validate_username
    if User.where(email: username).exists?
      errors.add(:username, :invalid)
    end
  end
  # -------------------------------------------------------------

  def avatar_thumbnail
    avatar.variant(resize_to_limit: [150, 150]).processed
  end

  def chat_avatar
    avatar.variant(resize_to_limit: [50, 50]).processed
  end

  def broadcast_update
    broadcast_replace_to 'user_status', partial: 'users/status', user: self
  end

  def status_to_css
    case status
    when 'online'
      'bg-success'
    when 'offline'
      'bg-dark'
    when 'away'
      'bg-warning'
    else
      'bg-dark'
    end
  end

  def has_joined_room(room)
    joined_rooms.include?(room)
  end

  private

  def add_default_avatar
    return if avatar.attached?

    avatar.attach(
      io: File.open(Rails.root.join('app', 'assets', 'images', 'default_avatar.jpg')),
      filename: 'default_avatar.jpg',
      content_type: 'image/jpg'
    )
  end

  def set_default_role
    #  If a role has not been set, set it to general
    self.role ||= :general
  end
end
