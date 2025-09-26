# frozen_string_literal: true

class NewsPolicy < ApplicationPolicy
  def index? = user_present?

  def batch_process? = user_present?

  def update? = user_present?

  private

  def user_present?
    user.present?
  end
end
