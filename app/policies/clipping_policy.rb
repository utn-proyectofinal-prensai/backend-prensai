# frozen_string_literal: true

class ClippingPolicy < ApplicationPolicy
  def index? = true

  def show? = true

  def create? = true

  def update? = true

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
