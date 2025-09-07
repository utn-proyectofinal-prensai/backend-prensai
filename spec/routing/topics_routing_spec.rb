# frozen_string_literal: true

describe API::V1::TopicsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/topics').to route_to('api/v1/topics#index', format: :json)
    end

    it 'routes to #create' do
      expect(post: '/api/v1/topics').to route_to('api/v1/topics#create', format: :json)
    end

    it 'routes to #update' do
      expect(put: '/api/v1/topics/1').to route_to('api/v1/topics#update', format: :json, id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/api/v1/topics/1').to route_to('api/v1/topics#destroy', format: :json, id: '1')
    end
  end
end
