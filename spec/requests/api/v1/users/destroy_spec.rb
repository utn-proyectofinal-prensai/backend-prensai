# frozen_string_literal: true

describe 'DELETE api/v1/users/:id' do
  let!(:target_user) { create(:user, :with_name) }
  let!(:other_user) { create(:user, :with_name) }

  context 'as admin user' do
    include_context 'authenticated admin user via JWT'
    
    context 'destroying another user' do
      subject { delete "/api/v1/users/#{target_user.id}", headers: auth_headers }

      it 'returns no content status' do
        subject
        expect(response).to have_http_status(:no_content)
      end

      it 'destroys the user' do
        expect { subject }.to change(User, :count).by(-1)
        expect { target_user.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'returns empty body' do
        subject
        expect(response.body).to be_empty
      end
    end

    context 'trying to destroy self' do
      subject { delete "/api/v1/users/#{admin_user.id}", headers: auth_headers }

      it 'returns forbidden status' do
        subject
        expect(response).to have_http_status(:forbidden)
      end

      it 'does not destroy the admin user' do
        expect { subject }.not_to change(User, :count)
        expect(admin_user.reload).to be_present
      end

      it 'returns error message' do
        subject
        expect(json[:errors]).to be_present
        expect(json[:errors].first[:message]).to be_present
      end
    end

    context 'when record is not found' do
        subject { delete "/api/v1/users/99999", headers: auth_headers }
    
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

  context 'as regular user' do
    include_context 'authenticated regular user via JWT'
    
    context 'trying to destroy another user' do
      subject { delete "/api/v1/users/#{target_user.id}", headers: auth_headers }

      it 'returns forbidden status' do
        subject
        expect(response).to have_http_status(:forbidden)
      end

      it 'does not destroy the user' do
        expect { subject }.not_to change(User, :count)
        expect(target_user.reload).to be_present
      end

      it 'returns error message' do
        subject
        expect(json[:errors]).to be_present
        expect(json[:errors].first[:message]).to be_present
      end
    end

    context 'trying to destroy self' do
      subject { delete "/api/v1/users/#{regular_user.id}", headers: auth_headers }

      it 'returns forbidden status' do
        subject
        expect(response).to have_http_status(:forbidden)
      end

      it 'does not destroy the user' do
        expect { subject }.not_to change(User, :count)
        expect(regular_user.reload).to be_present
      end

      it 'returns error message' do
        subject
        expect(json[:errors]).to be_present
        expect(json[:errors].first[:message]).to be_present
      end
    end
  end

  context 'when not authenticated' do
    let(:auth_headers) { {} }
    
          subject { delete "/api/v1/users/#{target_user.id}", headers: auth_headers }

    it 'returns unauthorized status' do
      subject
      expect(response).to have_http_status(:unauthorized)
    end

    it 'does not destroy the user' do
      expect { subject }.not_to change(User, :count)
      expect(target_user.reload).to be_present
    end

    it 'returns error message' do
      subject
      expect(json[:errors]).to be_present
      expect(json[:errors].first[:message]).to be_present
    end
  end  
end
