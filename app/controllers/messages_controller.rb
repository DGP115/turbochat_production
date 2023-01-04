# frozen_string_literal: true

# Controller for messages rooms
class MessagesController < ApplicationController
  def create
    @message = current_user.messages.create(body: whitelist_msg_params[:body],
                                            room_id: params[:room_id],
                                            attachments: whitelist_msg_params[:attachments])
  end

  private

  def whitelist_msg_params
    params.require(:message).permit(:body, attachments: [])
  end
end
