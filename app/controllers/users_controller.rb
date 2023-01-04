# frozen_string_literal: true

# Controller for app-specific, non-Devise user actions
class UsersController < ApplicationController
  def show
    # The below ensures that a user that is not logged in can't access user profiles
    # by entering routes directly in the browser address bar
    before_action :require_user, only: %i[edit update]

    @user = User.find(params[:id])
    @users = User.all_except(current_user)

    @room = Room.new
    @rooms = Room.public_rooms

    #   To enable direct chatting between two users:
    #   1.  Recall this Show action was invoked when a user clicked on another user's name in the
    #       room index.
    #   2.  So, the faciliate those two users chatting directly, we will create a room unique to
    #       this chat.
    @directmsg_room_name = get_directmsg_room_name(@user, current_user)
    @current_room = Room.where(name: @directmsg_room_name).first ||
                    Room.create_private_room([@user, current_user], @directmsg_room_name)

    @message = Message.new

    #  Using Pagy gem for pagination:
    #   1.  First variable, pagy_messages, comprises all messages in the room in descending order
    #   2.  When pagy is called, two variables are returned:  @pagy and the messages to display
    #   Since pagy_messages is in descending order, the second statement below returns the 20 most
    #   recent messages
    pagy_messages = @current_room.messages.order(created_at: :desc)
    @pagy, messages = pagy(pagy_messages, items: 20)
    #   3  Because we want to lopp through messages as message1, 2, 3, we have to reverse the order
    #      of "messages", above.  Put that reverse order in our @messages variable
    @messages = messages.reverse

    render 'rooms/index'
  end

  private

  def get_directmsg_room_name(user1, user2)
    #  Sort the users by id, so user1 initiating a chat with user2 forms the same room as user2
    #  initiating a chat with user1
    #  return a room name based on "private_" + user1.id + "_" + user2.id
    userlist = [user1, user2].sort
    "private_#{userlist[0].id}_#{userlist[1].id}"
  end
end
