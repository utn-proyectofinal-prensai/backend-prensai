# frozen_string_literal: true

require 'rails_helper'

describe 'ErrorsController' do
  describe 'GET /non-existent-route' do
    subject { get '/non-existent-route' }

    it 'returns 404 status' do
      subject
      expect(response).to have_http_status(:not_found)
    end

    it 'returns empty response body' do
      subject
      expect(response.body).to be_empty
    end

    it 'does not raise CSRF error' do
      expect { subject }.not_to raise_error
    end
  end

  describe 'POST /non-existent-route' do
    subject { post '/non-existent-route', params: { some: 'data' }, as: :json }

    it 'returns 404 status' do
      subject
      expect(response).to have_http_status(:not_found)
    end

    it 'returns empty response body' do
      subject
      expect(response.body).to be_empty
    end

    it 'does not raise CSRF error' do
      expect { subject }.not_to raise_error
    end
  end

  describe 'PUT /non-existent-route' do
    subject { put '/non-existent-route', params: { some: 'data' }, as: :json }

    it 'returns 404 status' do
      subject
      expect(response).to have_http_status(:not_found)
    end

    it 'returns empty response body' do
      subject
      expect(response.body).to be_empty
    end

    it 'does not raise CSRF error' do
      expect { subject }.not_to raise_error
    end
  end

  describe 'DELETE /non-existent-route' do
    subject { delete '/non-existent-route' }

    it 'returns 404 status' do
      subject
      expect(response).to have_http_status(:not_found)
    end

    it 'returns empty response body' do
      subject
      expect(response.body).to be_empty
    end

    it 'does not raise CSRF error' do
      expect { subject }.not_to raise_error
    end
  end

  describe 'PATCH /non-existent-route' do
    subject { patch '/non-existent-route', params: { some: 'data' }, as: :json }

    it 'returns 404 status' do
      subject
      expect(response).to have_http_status(:not_found)
    end

    it 'returns empty response body' do
      subject
      expect(response.body).to be_empty
    end

    it 'does not raise CSRF error' do
      expect { subject }.not_to raise_error
    end
  end

  describe 'GET /' do
    subject { get '/' }

    it 'returns 404 status for root path' do
      subject
      expect(response).to have_http_status(:not_found)
    end

    it 'returns empty response body for root path' do
      subject
      expect(response.body).to be_empty
    end

    it 'does not raise CSRF error' do
      expect { subject }.not_to raise_error
    end
  end
end
