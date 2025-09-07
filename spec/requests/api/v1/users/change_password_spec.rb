# frozen_string_literal: true

describe 'PATCH api/v1/users/:id/change_password' do
  let(:target_user) { create(:user, :with_name) }
  let(:new_password) { 'newSecurePassword123!' }
  let(:params) do
    {
      user: {
        password: new_password,
        password_confirmation: new_password
      }
    }
  end

  context 'when user is admin' do
    include_context 'with authenticated admin user via JWT'

    context 'when changing another user password' do
      subject { patch "/api/v1/users/#{target_user.id}/change_password", params:, headers: auth_headers, as: :json }

      context 'with valid params' do
        it 'returns success' do
          subject
          expect(response).to have_http_status(:success)
        end

        it 'updates the target user password' do
          original_encrypted_password = target_user.encrypted_password
          subject
          expect(target_user.reload.encrypted_password).not_to eq(original_encrypted_password)
        end

        it 'allows target user login with new password' do
          subject
          login_params = { user: { email: target_user.email, password: new_password } }
          post new_user_session_path, params: login_params, as: :json
          expect(response).to have_http_status(:success)
          expect(JSON.parse(response.body)['token']).to be_present
        end

        it 'prevents target user login with old password' do
          original_password = 'password' # Default password from factory
          subject
          login_params = { user: { email: target_user.email, password: original_password } }
          post new_user_session_path, params: login_params, as: :json
          expect(response).to have_http_status(:unauthorized)
        end

        it 'returns the updated user data' do
          subject
          expect(json[:user][:id]).to eq(target_user.id)
          expect(json[:user][:email]).to eq(target_user.email)
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
            original_encrypted_password = target_user.encrypted_password
            subject
            expect(target_user.reload.encrypted_password).to eq(original_encrypted_password)
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
            original_encrypted_password = target_user.encrypted_password
            subject
            expect(target_user.reload.encrypted_password).to eq(original_encrypted_password)
          end

          it 'returns validation errors' do
            subject
            expect(json[:errors]).to be_present
          end
        end
      end

      context 'when target user is not found' do
        subject { patch '/api/v1/users/99999/change_password', params:, headers: auth_headers, as: :json }

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

    context 'when changing own password' do
      subject { patch "/api/v1/users/#{admin_user.id}/change_password", params:, headers: auth_headers, as: :json }

      context 'with valid params' do
        it 'returns success' do
          subject
          expect(response).to have_http_status(:success)
        end

        it 'updates own password' do
          original_encrypted_password = admin_user.encrypted_password
          subject
          expect(admin_user.reload.encrypted_password).not_to eq(original_encrypted_password)
        end

        it 'allows login with new password' do
          subject
          login_params = { user: { email: admin_user.email, password: new_password } }
          post new_user_session_path, params: login_params, as: :json
          expect(response).to have_http_status(:success)
          expect(JSON.parse(response.body)['token']).to be_present
        end
      end
    end
  end

  context 'when user is regular' do
    include_context 'with authenticated regular user via JWT'

    context 'when trying to change another user password' do
      subject { patch "/api/v1/users/#{target_user.id}/change_password", params:, headers: auth_headers, as: :json }

      it 'returns forbidden status' do
        subject
        expect(response).to have_http_status(:forbidden)
      end

      it 'does not update the target user password' do
        original_encrypted_password = target_user.encrypted_password
        subject
        expect(target_user.reload.encrypted_password).to eq(original_encrypted_password)
      end

      it 'returns error message' do
        subject
        expect(json[:errors]).to be_present
        expect(json[:errors].first[:message]).to be_present
      end
    end

    context 'when trying to change own password via users/:id route' do
      subject { patch "/api/v1/users/#{regular_user.id}/change_password", params:, headers: auth_headers, as: :json }

      it 'returns success' do
        subject
        expect(response).to have_http_status(:success)
      end

      it 'updates own password' do
        original_encrypted_password = regular_user.encrypted_password
        subject
        expect(regular_user.reload.encrypted_password).not_to eq(original_encrypted_password)
      end

      it 'allows login with new password' do
        subject
        login_params = { user: { email: regular_user.email, password: new_password } }
        post new_user_session_path, params: login_params, as: :json
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['token']).to be_present
      end
    end
  end

  context 'when not authenticated' do
    subject { patch "/api/v1/users/#{target_user.id}/change_password", params:, headers: auth_headers, as: :json }

    let(:auth_headers) { {} }

    it 'returns unauthorized status' do
      subject
      expect(response).to have_http_status(:unauthorized)
    end

    it 'does not update the user password' do
      original_encrypted_password = target_user.encrypted_password
      subject
      expect(target_user.reload.encrypted_password).to eq(original_encrypted_password)
    end

    it 'returns error message' do
      subject
      expect(json[:errors]).to be_present
      expect(json[:errors].first[:message]).to be_present
    end
  end
end
