# frozen_string_literal: true

class MetricSnapshotPolicy < ApplicationPolicy
  def show?
    user.present?
  end
end
