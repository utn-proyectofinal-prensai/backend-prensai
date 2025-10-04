# frozen_string_literal: true

describe 'DELETE /api/v1/clippings/:id' do
  subject(:request_destroy) { delete api_v1_clipping_path(clipping), headers: auth_headers, as: :json }

  context 'when authenticated as admin user' do
    include_context 'with authenticated admin user via JWT'

    let(:clipping) { create(:clipping) }

    before { clipping }

    it 'destroys the clipping' do
      expect { request_destroy }.to change(Clipping, :count).by(-1)
    end

    it 'returns no content status' do
      request_destroy
      expect(response).to have_http_status(:no_content)
    end
  end

  context 'when authenticated as the creator' do
    include_context 'with authenticated regular user via JWT'

    let(:clipping) { create(:clipping, creator: regular_user) }

    before { clipping }

    it 'destroys the clipping' do
      expect { request_destroy }.to change(Clipping, :count).by(-1)
    end

    it 'returns no content status' do
      request_destroy
      expect(response).to have_http_status(:no_content)
    end
  end

  context 'when authenticated as a different regular user' do
    include_context 'with authenticated regular user via JWT'

    let(:clipping) { create(:clipping) }

    before { clipping }

    it 'does not destroy the clipping' do
      expect { request_destroy }.not_to change(Clipping, :count)
    end

    it 'returns forbidden status' do
      request_destroy
      expect(response).to have_http_status(:forbidden)
    end
  end
end
