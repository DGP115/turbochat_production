# frozen_string_literal: true

#  These methods are accessible in Controllers
module RoomsHelper
  #  User enters start of a room name in search bar.
  #  Look for rooms with names like the criteria entered.  Return an array of rooms.
  def search_rooms
    if params[:name_search].present? && params[:name_search].length.positive?
      Room.public_rooms
          .where.not(id: current_user.joined_rooms.pluck(:id))
          .where('name ILIKE ?', "%#{params[:name_search]}%")
          .order(name: :asc)
    else
      []
    end
  end
end
