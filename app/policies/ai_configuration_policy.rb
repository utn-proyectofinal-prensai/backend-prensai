# frozen_string_literal: true

class AiConfigurationPolicy < ApplicationPolicy
  def index? = user.admin?

  def update? = user.admin?
end
