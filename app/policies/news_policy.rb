# frozen_string_literal: true

class NewsPolicy < ApplicationPolicy
  def index? = true

  def batch_process? = true
end
