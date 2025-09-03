# frozen_string_literal: true

class TopicPolicy < ApplicationPolicy
  def index? = true

  def create? = true

  def update? = true

  def destroy? = true
end
