# frozen_string_literal: true

describe 'GET api/v1/users' do
  subject { get api_v1_users_path, headers: auth_headers, as: :json }

  let!(:user1) { create(:user, :with_name) }
  let!(:user2) { create(:user, :with_name) }

  context 'when authenticated as admin user' do
    include_context 'authenticated admin user via JWT'

    it 'returns a successful response' do
      subject
      expect(response).to have_http_status(:success)
    end

    it 'returns all users including admin', :aggregate_failures do
      subject
      expect(json[:users]).to be_an(Array)
      expect(json[:users].size).to eq(3) # admin_user + user1 + user2
      
      # Verificar que incluye todos los usuarios
      user_ids = json[:users].pluck(:id)
      expect(user_ids).to include(admin_user.id, user1.id, user2.id)
    end

    it 'returns correct user data structure for each user', :aggregate_failures do
      subject
      first_user = json[:users].first
      
      expect(first_user).to have_key(:id)
      expect(first_user).to have_key(:email)
      expect(first_user).to have_key(:username)
      expect(first_user).to have_key(:first_name)
      expect(first_user).to have_key(:last_name)
      expect(first_user).to have_key(:role)
      expect(first_user).to have_key(:created_at)
      expect(first_user).to have_key(:updated_at)
    end

    it 'includes users with different roles', :aggregate_failures do
      subject
      user_roles = json[:users].pluck(:role)
      expect(user_roles).to include('admin', 'user')
    end
  end

  context 'when authenticated as regular user' do
    include_context 'authenticated regular user via JWT'

    it 'returns a successful response' do
      subject
      expect(response).to have_http_status(:success)
    end

    it 'returns only the current user data', :aggregate_failures do
      subject
      expect(json[:users]).to be_an(Array)
      expect(json[:users].size).to eq(1)
      expect(json[:users].first[:id]).to eq(regular_user.id)
      expect(json[:users].first[:email]).to eq(regular_user.email)
      expect(json[:users].first[:role]).to eq('user')
    end

    it 'does not return other users data', :aggregate_failures do
      subject
      user_ids = json[:users].pluck(:id)
      expect(user_ids).not_to include(user1.id, user2.id)
    end
  end

  context 'when not authenticated' do
    let(:auth_headers) { {} }

    it 'returns unauthorized status' do
      subject
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns error message' do
      subject
      expect(json[:errors]).to be_present
      expect(json[:errors].first[:message]).to be_present
    end
  end

  context 'when authenticated with invalid token' do
    let(:auth_headers) { { 'Authorization' => 'Bearer invalid_token' } }

    it 'returns unauthorized status' do
      subject
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns error message' do
      subject
      expect(json[:errors]).to be_present
      expect(json[:errors].first[:message]).to be_present
    end
  end
end
