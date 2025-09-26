# frozen_string_literal: true

describe 'PATCH api/v1/user/change_password' do
  subject { patch '/api/v1/user/change_password', params:, headers: auth_headers, as: :json }

  let(:new_password) { 'newSecurePassword123!' }
  let(:params) do
    {
      user: {
        password: new_password,
        password_confirmation: new_password
      }
    }
  end

  context 'when user is authenticated' do
    include_context 'with authenticated regular user via JWT'

    context 'with valid params' do
      it 'returns success' do
        subject
        expect(response).to have_http_status(:success)
      end

      it 'updates the user password' do
        original_encrypted_password = regular_user.encrypted_password
        subject
        expect(regular_user.reload.encrypted_password).not_to eq(original_encrypted_password)
      end

      it 'allows login with new password' do
        subject
        login_params = { user: { email: regular_user.email, password: new_password } }
        post new_user_session_path, params: login_params, as: :json
        expect(response).to have_http_status(:success)
        expect(response.parsed_body['token']).to be_present
      end

      it 'prevents login with old password' do
        subject
        login_params = { user: { email: regular_user.email, password: 'password' } }
        post new_user_session_path, params: login_params, as: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns the updated user data' do
        subject
        expect(json[:user][:id]).to eq(regular_user.id)
        expect(json[:user][:email]).to eq(regular_user.email)
      end
    end

    context 'with invalid params' do
      context 'when password confirmation does not match' do
        let(:params) do
          {
            user: {
              password: new_password,
              password_confirmation: 'differentPassword123!'
            }
          }
        end

        it 'returns unprocessable entity status' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not update the password' do
          original_encrypted_password = regular_user.encrypted_password
          subject
          expect(regular_user.reload.encrypted_password).to eq(original_encrypted_password)
        end

        it 'returns validation errors' do
          subject
          expect(json[:errors]).to be_present
        end
      end

      context 'when password is too short' do
        let(:params) do
          {
            user: {
              password: '123',
              password_confirmation: '123'
            }
          }
        end

        it 'returns unprocessable entity status' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not update the password' do
          original_encrypted_password = regular_user.encrypted_password
          subject
          expect(regular_user.reload.encrypted_password).to eq(original_encrypted_password)
        end

        it 'returns validation errors' do
          subject
          expect(json[:errors]).to be_present
        end
      end

      context 'when user parameter is missing' do
        let(:params) do
          {
            password: new_password,
            password_confirmation: new_password
          }
        end

        it 'returns bad request status' do
          subject
          expect(response).to have_http_status(:bad_request)
        end

        it 'returns parameter missing error' do
          subject
          expect(json[:errors]).to be_present
          expect(json[:errors].first[:message]).to be_present
        end
      end
    end
  end

  context 'when user is admin' do
    include_context 'with authenticated admin user via JWT'

    context 'with valid params' do
      it 'returns success' do
        subject
        expect(response).to have_http_status(:success)
      end

      it 'updates the admin user password' do
        original_encrypted_password = admin_user.encrypted_password
        subject
        expect(admin_user.reload.encrypted_password).not_to eq(original_encrypted_password)
      end

      it 'allows admin login with new password' do
        subject
        login_params = { user: { email: admin_user.email, password: new_password } }
        post new_user_session_path, params: login_params, as: :json
        expect(response).to have_http_status(:success)
        expect(response.parsed_body['token']).to be_present
      end
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
end
