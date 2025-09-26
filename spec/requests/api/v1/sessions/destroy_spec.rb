# frozen_string_literal: true

describe 'DELETE api/v1/users/sign_out' do
  let(:user) { create(:user) }
  let(:auth_headers) { auth_headers_for(user) }

  context 'with a valid token' do
    it 'returns a no content response' do
      delete destroy_user_session_path, headers: auth_headers, as: :json
      expect(response).to have_http_status(:no_content)
    end

    it 'revokes the JWT token' do
      expect {
        delete destroy_user_session_path, headers: auth_headers, as: :json
      }.to change(JwtDenylist, :count).by(1)
    end
  end

  context 'without a valid token' do
    it 'still returns no content' do
      expect {
        delete destroy_user_session_path, headers: {}, as: :json
      }.not_to change(JwtDenylist, :count)

      expect(response).to have_http_status(:no_content)
    end
  end
end
