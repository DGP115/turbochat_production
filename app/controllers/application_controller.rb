# frozen_string_literal: true

# Base call for app-specific controllers
class ApplicationController < ActionController::Base
  include Pagy::Backend

  # This statement means the helper methods can also be used in Views
  helper_method :logged_in?

  # Adding customization to have Devise use username instead of email as login
  before_action :configure_permitted_parameters, if: :devise_controller?

  # More Infinite scrolling setup
  before_action :turbo_frame_request_variant

  private

  def turbo_frame_request_variant
    request.variant = :turbo_frame if turbo_frame_request?
  end

  def logged_in?
    if current_user
      true
    else
      false
    end
  end

  # rubocop prefers the style used below:
  # def require_user
  #   if !loggin_in?
  #     flash[:alert] = 'You must be logged in to perform that action'
  #     redirect_to login_path
  #   end
  # end
  #  --- This method protects the app from users who know enough to type
  #      valid routes into the browser address bar
  def require_user
    return if logged_in?

    flash[:alert] = 'You must be logged in to perform that action'
    redirect_to new_user_session_path
  end

  protected

  def configure_permitted_parameters
    added_attrs = %i[username email password password_confirmation remember_me]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :sign_in, keys: %i[login password]
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end
end
