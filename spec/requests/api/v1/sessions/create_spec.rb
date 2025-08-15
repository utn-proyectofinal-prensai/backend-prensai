# frozen_string_literal: true

describe 'POST api/v1/users/sign_in' do
  subject { post new_user_session_path, params:, as: :json }

  let(:password) { 'password' }
  let(:user) { create(:user, password:) }
  let(:params) do
    {
      user:
        {
          email: user.email,
          password:
        }
    }
  end

  context 'with correct params' do
    before do
      subject
    end

    it_behaves_like 'there must not be a Set-Cookie in Header'
    it_behaves_like 'does not check authenticity token'

    it 'returns success' do
      expect(response).to be_successful
    end

    it 'returns token and metadata' do
      expect(json[:token]).to be_present
      expect(json[:token_type]).to eq('Bearer')
      expect(json[:expires_in]).to be_present
    end

    it 'includes custom claims in JWT' do
      token = json[:token]
      payload, = JWT.decode(token, Rails.application.secret_key_base, true, { algorithm: 'HS256' })
      expect(payload['sub'].to_s).to eq(user.id.to_s)
      expect(payload['role']).to eq(user.role)
      expect(payload['email']).to eq(user.email)
      expect(payload['full_name']).to eq(user.full_name)
    end
  end

  context 'with incorrect params' do
    let(:params) do
      {
        user: {
          email: user.email,
          password: 'wrong_password!'
        }
      }
    end

    it 'returns to be unauthorized' do
      subject
      expect(response).to be_unauthorized
    end

    it 'return errors upon failure' do
      subject
      expect(json[:errors]).to be_present
      expect(json[:errors].first[:message]).to include('Credenciales inválidas')
    end
  end
end
