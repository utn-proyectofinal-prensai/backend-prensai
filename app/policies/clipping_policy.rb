# frozen_string_literal: true

class ClippingPolicy < ApplicationPolicy
  def index? = user.present?

  def show? = user.present?

  def create? = user.present?

  def update?
    can_manage?
  end

  def destroy?
    can_manage?
  end

  def generate_report?
    can_manage?
  end

  def update_report?
    can_manage?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end

  private

  def can_manage?
    return false if user.blank?

    user.admin? || record.creator_id == user.id
  end
end
