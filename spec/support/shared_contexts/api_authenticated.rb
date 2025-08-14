# frozen_string_literal: true

RSpec.shared_context 'authenticated admin user via JWT' do
  let!(:admin_user) { create(:user, :admin, password: 'password') }
  let(:auth_token) do
    # Generate a real JWT token using Devise-JWT
    login_params = { user: { email: admin_user.email, password: 'password' } }
    post new_user_session_path, params: login_params, as: :json
    JSON.parse(response.body)['token']
  end
  let(:auth_headers) { { 'Authorization' => "Bearer #{auth_token}" } }
end

RSpec.shared_context 'authenticated regular user via JWT' do
  let!(:regular_user) { create(:user, password: 'password') }
  let(:auth_token) do
    # Generate a real JWT token using Devise-JWT
    login_params = { user: { email: regular_user.email, password: 'password' } }
    post new_user_session_path, params: login_params, as: :json
    JSON.parse(response.body)['token']
  end
  let(:auth_headers) { { 'Authorization' => "Bearer #{auth_token}" } }
end
