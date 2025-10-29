# frozen_string_literal: true

class DashboardSnapshotPolicy < ApplicationPolicy
  def show?
    user.present?
  end
end
