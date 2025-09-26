# frozen_string_literal: true

describe API::V1::NewsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/news').to route_to('api/v1/news#index', format: :json)
    end

    it 'routes to #update via PUT' do
      expect(put: '/api/v1/news/1').to route_to('api/v1/news#update', id: '1', format: :json)
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/api/v1/news/1').to route_to('api/v1/news#update', id: '1', format: :json)
    end

    it 'routes to #batch_process' do
      expect(post: '/api/v1/news/batch_process').to route_to('api/v1/news#batch_process', format: :json)
    end
  end
end
