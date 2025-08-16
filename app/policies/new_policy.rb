class NewPolicy < ApplicationPolicy
  def index? = true

  def batch_process? = true
end
