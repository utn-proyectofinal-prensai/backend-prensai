# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  after_action :verify_authorized,
               except: :index,
               unless: -> { devise_controller? || active_admin_controller? || errors_controller? }
  after_action :verify_policy_scoped,
               only: :index,
               unless: -> { devise_controller? || active_admin_controller? || errors_controller? }
  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception

  around_action :use_active_admin_locale, if: :active_admin_controller?

  def active_admin_controller?
    is_a?(ActiveAdmin::BaseController)
  end

  def errors_controller?
    is_a?(ErrorsController)
  end

  def use_active_admin_locale(&)
    I18n.with_locale(:en, &)
  end
end
