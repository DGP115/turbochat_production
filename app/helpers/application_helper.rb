# frozen_string_literal: true

# Methods used in View pages
module ApplicationHelper
  #
  #  Pagy is a gem used for pagination
  include Pagy::Frontend
  # Create a funny avator for each user, using a hash of their username

  def avatar_for_name(name, options = { size: '300x300' })
    hash = Digest::MD5.hexdigest(name)
    size = options[:size]
    robot_url = "https://robohash.org/#{hash}.png/bgset_any?size=#{size}"
    image_tag(robot_url, alt: name, class: 'rounded-circle shadow')
  end
end
