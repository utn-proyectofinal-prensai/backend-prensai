# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index? = user.admin?

  def show? = user.admin? || user.id == record.id

  def create? = user.admin?

  def update? = user.admin? || user.id == record.id

  def destroy? = user.admin? && user.id != record.id

  def permitted_attributes
    base = %i[username first_name last_name email]
    user.admin? ? base + %i[role password password_confirmation] : base
  end

  class Scope < Scope
    def resolve
      user.admin? ? scope.all : scope.where(id: user.id)
    end
  end
end
