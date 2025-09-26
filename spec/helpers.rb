# frozen_string_literal: true

module Helpers
  # Helper method to parse a response
  #
  # @return [Hash]
  def json
    JSON.parse(response.body).with_indifferent_access
  end

  def auth_headers_for(token_user)
    raise ArgumentError, 'A user instance is required to build auth headers' unless token_user

    token, _payload = Warden::JWTAuth::UserEncoder.new.call(token_user, :user, nil)
    { 'Authorization' => "Bearer #{token}" }
  end

  def auth_headers
    raise ArgumentError, 'Define a user with let(:user) to build auth headers' unless respond_to?(:user)

    auth_headers_for(user)
  end
end
