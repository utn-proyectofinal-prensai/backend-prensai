# frozen_string_literal: true

class TopicPolicy < ApplicationPolicy
  def index? = user_present?

  def create? = user_present?

  def update? = user_present?

  def destroy? = user_present?

  private

  def user_present?
    user.present?
  end
end
