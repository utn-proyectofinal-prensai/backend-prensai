# frozen_string_literal: true

describe 'PUT/PATCH api/v1/users/:id' do
  let(:target_user) { create(:user, :with_name) }
  let(:other_user) { create(:user, :with_name) }

  context 'when user is admin' do
    include_context 'with authenticated admin user via JWT'

    context 'when updating another user' do
      subject { put "/api/v1/users/#{target_user.id}", params:, headers: auth_headers, as: :json }

      context 'with valid params' do
        let(:params) { { user: { username: 'admin_updated_username' } } }

        it 'returns success' do
          subject
          expect(response).to have_http_status(:success)
        end

        it 'updates the target user' do
          subject
          expect(target_user.reload.username).to eq(params[:user][:username])
        end

        it 'returns the updated user data' do
          subject
          expect(json[:user][:id]).to eq(target_user.id)
          expect(json[:user][:username]).to eq('admin_updated_username')
        end
      end

      context 'with role update' do
        let(:params) { { user: { role: 'admin' } } }

        it 'returns success' do
          subject
          expect(response).to have_http_status(:success)
        end

        it 'updates the user role' do
          subject
          expect(target_user.reload.role).to eq('admin')
        end

        it 'returns the updated role' do
          subject
          expect(json[:user][:role]).to eq('admin')
        end
      end

      context 'with password change attempt' do
        let(:params) do
          { user: { username: 'test', password: 'newpassword123', password_confirmation: 'newpassword123' } }
        end

        it 'ignores password parameter' do
          subject
          expect(response).to have_http_status(:success)
        end

        it 'does not change the password' do
          original_password_digest = target_user.encrypted_password
          subject
          expect(target_user.reload.encrypted_password).to eq(original_password_digest)
        end
      end

      context 'with invalid data' do
        let(:params) { { user: { email: 'notanemail' } } }

        it 'does not return success' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not update the user' do
          original_email = target_user.email
          subject
          expect(target_user.reload.email).to eq(original_email)
        end

        it 'returns validation errors' do
          subject
          expect(json[:errors]).to be_present
        end
      end
    end

    context 'when updating self' do
      subject { put "/api/v1/users/#{admin_user.id}", params:, headers: auth_headers, as: :json }

      context 'with valid params' do
        let(:params) { { user: { username: 'admin_self_update' } } }

        it 'returns success' do
          subject
          expect(response).to have_http_status(:success)
        end

        it 'updates own profile' do
          subject
          expect(admin_user.reload.username).to eq('admin_self_update')
        end
      end
    end

    context 'when record is not found' do
      subject { put '/api/v1/users/99999', params:, headers: auth_headers, as: :json }

      let(:params) { { user: { username: 'not_found_test' } } }

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

    context 'when trying to update another user' do
      subject { put "/api/v1/users/#{target_user.id}", params:, headers: auth_headers, as: :json }

      let(:params) { { user: { username: 'hacker_attempt' } } }

      it 'returns forbidden status' do
        subject
        expect(response).to have_http_status(:forbidden)
      end

      it 'does not update the target user' do
        original_username = target_user.username
        subject
        expect(target_user.reload.username).to eq(original_username)
      end

      it 'returns error message' do
        subject
        expect(json[:errors]).to be_present
        expect(json[:errors].first[:message]).to be_present
      end
    end

    context 'when trying to update self' do
      subject { put "/api/v1/users/#{regular_user.id}", params:, headers: auth_headers, as: :json }

      let(:params) { { user: { username: 'self_attempt' } } }

      it 'returns forbidden status' do
        subject
        expect(response).to have_http_status(:forbidden)
      end

      it 'does not update own profile' do
        original_username = regular_user.username
        subject
        expect(regular_user.reload.username).to eq(original_username)
      end

      it 'returns error message' do
        subject
        expect(json[:errors]).to be_present
        expect(json[:errors].first[:message]).to be_present
      end
    end
  end

  context 'when not authenticated' do
    subject { put "/api/v1/users/#{target_user.id}", params:, headers: auth_headers, as: :json }

    let(:auth_headers) { {} }
    let(:params) { { user: { username: 'unauthorized_attempt' } } }

    it 'returns unauthorized status' do
      subject
      expect(response).to have_http_status(:unauthorized)
    end

    it 'does not update the user' do
      original_username = target_user.username
      subject
      expect(target_user.reload.username).to eq(original_username)
    end

    it 'returns error message' do
      subject
      expect(json[:errors]).to be_present
      expect(json[:errors].first[:message]).to be_present
    end
  end
end
