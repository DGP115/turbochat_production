# frozen_string_literal: true

# Controller for chat rooms
class RoomsController < ApplicationController
  include RoomsHelper
  #  The authenticate_user! method comes from Devise
  before_action :authenticate_user!, except: %i[list]
  before_action :set_status

  def index
    @room = Room.new
    @joined_rooms = current_user.joined_rooms.order(last_message_at: :desc)
    @rooms = search_rooms

    @users = User.all_except(current_user)

    render 'index'
  end

  def create
    @room = Room.create(whitelist_room_params)
    redirect_to @room
  end

  def show
    @current_room = Room.find(params[:id])

    @room = Room.new
    @joined_rooms = current_user.joined_rooms.order(last_message_at: :desc)
    @rooms = search_rooms

    @message = Message.new

    #  Using Pagy gem for pagination:
    #   1.  First variable, pagy_messages, comprises all messages in the room in descending order
    #   2.  When pagy is called, two variables are returned:  @pagy and the messages to display
    #   Since pagy_messages is in descending order, the second statement below returns the 20 most
    #   recent messages
    pagy_messages = @current_room.messages.includes(:user, :attachments_attachments,
                                            attachments_attachments: :blob).order(created_at: :desc)
    @pagy, messages = pagy(pagy_messages, items: 10)
    #   3  Because we want to lopp through messages as message1, 2, 3, we have to reverse the order
    #      of "messages", above.  Put that reverse order in our @messages variable
    @messages = messages.reverse

    @users = User.all_except(current_user)

    render 'index'
  end

  def list
    @public_rooms = Room.public_rooms
  end

  def edit
    set_room
  end

  def update
    set_room
    if @room.update(whitelist_room_params)
      flash[:notice] = 'The Room was updated successfully.'
      redirect_to roomslist_path
    else
      # Error trapping
      # Re-render the "edit" page.
      # Because the save returned false, the error trapping on the "edit" page
      # will display the errors
      render 'edit', status: :unprocessable_entity
    end
  end

  def admin
    @public_rooms = Room.public_rooms
    @private_rooms = Room.private_rooms
    @participants = Participant.all
  end

  def destroy
    set_room

    if @room.destroy
      #
      # Generate a confirmation message for the user.
      flash[:notice] = 'The Room was deleted successfully.'

      redirect_to rooms_admin_path

    else

      # Error trapping
      # Re-render the "edit" article page.
      # Because the save returned false, the error trapping on the "edit" page
      # will display the errors
      render 'admin', status: :unprocessable_entity
    end
  end

  def search
    @rooms = search_rooms
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update('search_results',
                              partial: 'rooms/search_results',
                              locals: { rooms: @rooms })
        ]
      end
    end
  end

  def join
    #  This method is invoked when a user selectes to join a room
    #  So, get the room they identified and add it to their list of joined rooms
    @room = Room.find(params[:id])
    current_user.joined_rooms << @room
    #  Then take the user to that room
    redirect_to @room
  end

  def leave
    #  This method is invoked when a user selectes to leave a room
    #  So, get the room they identified and remove it from their list of joined rooms
    @room = Room.find(params[:id])
    current_user.joined_rooms.delete(@room)
    #  Then take the user to the rooms index
    redirect_to rooms_path
  end

  private

  def set_room
    @room = Room.find(params[:id])
  end

  def whitelist_room_params
    params.require(:room).permit(:name, :description)
  end

  def set_status
    current_user&.update!(status: User.statuses[:online])
  end
end
