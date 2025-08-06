class User < ApplicationRecord
  has_secure_password
  
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  validates :role, presence: true, inclusion: { in: %w[admin user] }
  
  before_validation :set_default_role, on: :create
  
  private
  
  def set_default_role
    self.role ||= 'user'
  end
end