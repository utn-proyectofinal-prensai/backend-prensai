# frozen_string_literal: true

describe API::V1::MentionsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/mentions').to route_to('api/v1/mentions#index', format: :json)
    end

    it 'routes to #create' do
      expect(post: '/api/v1/mentions').to route_to('api/v1/mentions#create', format: :json)
    end

    it 'routes to #update' do
      expect(put: '/api/v1/mentions/1').to route_to('api/v1/mentions#update', format: :json, id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/api/v1/mentions/1').to route_to('api/v1/mentions#destroy', format: :json, id: '1')
    end
  end
end
