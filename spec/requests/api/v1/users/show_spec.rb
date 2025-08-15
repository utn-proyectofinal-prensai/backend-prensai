# frozen_string_literal: true

describe 'GET api/v1/users/:id' do
  let(:target_user) { create(:user, :with_name) }
  let(:other_user) { create(:user, :with_name) }

  context 'when user is admin' do
    include_context 'with authenticated admin user via JWT'

    context 'when viewing another user' do
      subject { get "/api/v1/users/#{target_user.id}", headers: auth_headers }

      it 'returns success' do
        subject
        expect(response).to have_http_status(:success)
      end

      it 'returns the requested user data', :aggregate_failures do
        subject
        expect(json[:user][:id]).to eq(target_user.id)
        expect(json[:user][:email]).to eq(target_user.email)
        expect(json[:user][:name]).to eq(target_user.full_name)
        expect(json[:user][:role]).to eq(target_user.role)
      end
    end

    context 'when viewing self' do
      subject { get "/api/v1/users/#{admin_user.id}", headers: auth_headers }

      it 'returns success' do
        subject
        expect(response).to have_http_status(:success)
      end

      it 'returns own user data' do
        subject
        expect(json[:user][:id]).to eq(admin_user.id)
        expect(json[:user][:email]).to eq(admin_user.email)
        expect(json[:user][:role]).to eq(admin_user.role)
      end
    end

    context 'when record is not found' do
      subject { get '/api/v1/users/99999', headers: auth_headers }

      it 'returns status 404 not found' do
        subject
        expect(response).to have_http_status(:not_found)
      end

      it 'returns error message' do
        subject
        expect(json[:errors]).to be_present
        expect(json[:errors].first[:message]).to be_present
      end
    end
  end

  context 'when user is regular' do
    include_context 'with authenticated regular user via JWT'

    context 'when viewing another user' do
      subject { get "/api/v1/users/#{target_user.id}", headers: auth_headers }

      it 'returns forbidden status' do
        subject
        expect(response).to have_http_status(:forbidden)
      end

      it 'returns error message' do
        subject
        expect(json[:errors]).to be_present
        expect(json[:errors].first[:message]).to be_present
      end
    end

    context 'when viewing self' do
      subject { get "/api/v1/users/#{regular_user.id}", headers: auth_headers }

      it 'returns success' do
        subject
        expect(response).to have_http_status(:success)
      end

      it 'returns own user data' do
        subject
        expect(json[:user][:id]).to eq(regular_user.id)
        expect(json[:user][:email]).to eq(regular_user.email)
        expect(json[:user][:name]).to eq(regular_user.full_name)
        expect(json[:user][:role]).to eq(regular_user.role)
      end
    end
  end

  context 'when not authenticated' do
    subject { get "/api/v1/users/#{target_user.id}", headers: auth_headers }

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

  context 'when accessing current user profile (/api/v1/user)' do
    subject { get api_v1_user_path, headers: auth_headers }

    include_context 'with authenticated regular user via JWT'

    it_behaves_like 'there must not be a Set-Cookie in Header'

    it 'returns success' do
      subject
      expect(response).to have_http_status(:success)
    end

    it "returns the logged in user's id" do
      subject
      expect(json[:user][:id]).to eq(regular_user.id)
    end

    it "returns the logged in user's full_name" do
      subject
      expect(json[:user][:name]).to eq(regular_user.full_name)
    end

    it "returns the logged in user's email" do
      subject
      expect(json[:user][:email]).to eq(regular_user.email)
    end

    it "returns the logged in user's role" do
      subject
      expect(json[:user][:role]).to eq(regular_user.role)
    end
  end
end
