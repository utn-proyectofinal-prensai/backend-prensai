# frozen_string_literal: true

class MentionPolicy < ApplicationPolicy
  def index? = true

  def create? = true
end
