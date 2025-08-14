# frozen_string_literal: true

describe 'POST api/v1/users' do
  include_context 'authenticated admin user via JWT'
  
  subject { post api_v1_users_path, params:, headers: auth_headers, as: :json }

  let(:created_user) { User.find_by(email:) }
  let(:email) { 'newuser@example.com' }
  let(:params) do
    {
      user: {
        username: 'testuser',
        email:,
        password: '12345678',
        password_confirmation: '12345678',
        role: 'user',
        first_name: 'Johnny',
        last_name: 'Perez'
      }
    }
  end

  it 'returns a successful response' do
    subject
    expect(response).to have_http_status(:success)
  end

  it 'creates the user' do
    # Admin user is already created by the shared context
    initial_count = User.count
    subject
    expect(User.count).to eq(initial_count + 1)
  end

  it 'returns the user data', :aggregate_failures do
    subject
    expect(json[:user][:id]).to eq(created_user.id)
    expect(json[:user][:email]).to eq(created_user.email)
    expect(json[:user][:username]).to eq(created_user.username)
    expect(json[:user][:first_name]).to eq(created_user.first_name)
    expect(json[:user][:last_name]).to eq(created_user.last_name)
    expect(json[:user][:role]).to eq(created_user.role)
  end

  context 'when the email is not correct' do
    let(:email) { 'invalid_email' }

    it 'does not create a user' do
      initial_count = User.count
      subject
      expect(User.count).to eq(initial_count)
    end

    it 'does not return a successful response' do
      subject
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  context 'when the password is incorrect' do
    before do
      params[:user].merge!({ password: 'short', password_confirmation: 'short' })
    end

    it 'does not create a user' do
      initial_count = User.count
      subject
      expect(User.count).to eq(initial_count)
    end

    it 'does not return a successful response' do
      subject
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  context 'when passwords don\'t match' do
    before do
      params[:user].merge!({ password: 'shouldmatch', password_confirmation: 'dontmatch' })
    end

    it 'does not create a user' do
      initial_count = User.count
      subject
      expect(User.count).to eq(initial_count)
    end

    it 'does not return a successful response' do
      subject
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
