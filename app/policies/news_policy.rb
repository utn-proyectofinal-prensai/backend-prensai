# frozen_string_literal: true

class NewsPolicy < ApplicationPolicy
  def index? = true

  def show? = true

  def batch_process? = true

  def review? = user.present?
end
