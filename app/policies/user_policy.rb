# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index? = user.admin?

  def show? = user.admin? || user.id == record.id

  def create? = user.admin?

  def update? = user.admin?

  def destroy? = user.admin? && user.id != record.id

  def permitted_attributes
    %i[username first_name last_name email role password password_confirmation]
  end

  class Scope < Scope
    def resolve
      user.admin? ? scope.all : scope.where(id: user.id)
    end
  end
end
