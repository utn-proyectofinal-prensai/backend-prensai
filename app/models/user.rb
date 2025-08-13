# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  allow_password_change  :boolean          default(FALSE), not null
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  email                  :string
#  encrypted_password     :string           default(""), not null
#  first_name             :string           default("")
#  last_name              :string           default("")
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :string           default("user"), not null
#  sign_in_count          :integer          default(0), not null
#  tokens                 :json
#  username               :string           default("")
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_role                  (role)
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :trackable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  validates :role, presence: true, inclusion: { in: %w[admin user] }

  enum :role, { user: 'user', admin: 'admin' }, default: 'user'

  attribute :impersonated_by, :integer

  RANSACK_ATTRIBUTES = %w[id email first_name last_name username sign_in_count current_sign_in_at
                          last_sign_in_at current_sign_in_ip last_sign_in_ip
                          role created_at updated_at].freeze

  def full_name
    return username if first_name.blank?

    "#{first_name} #{last_name}"
  end

  def jwt_payload
    {
      'role' => role,
      'email' => email,
      'full_name' => full_name
    }
  end
end
