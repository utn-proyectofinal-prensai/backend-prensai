# frozen_string_literal: true

describe API::V1::ClippingsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/clippings').to route_to('api/v1/clippings#index', format: :json)
    end

    it 'routes to #create' do
      expect(post: '/api/v1/clippings').to route_to('api/v1/clippings#create', format: :json)
    end

    it 'routes to #update via PUT' do
      expect(put: '/api/v1/clippings/1').to route_to('api/v1/clippings#update', id: '1', format: :json)
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/api/v1/clippings/1').to route_to('api/v1/clippings#update', id: '1', format: :json)
    end

    it 'routes to clipping report#create via POST' do
      expect(post: '/api/v1/clippings/1/report').to route_to(
        'api/v1/clippings/reports#create',
        clipping_id: '1',
        format: :json
      )
    end

    it 'routes to clipping report#show via GET' do
      expect(get: '/api/v1/clippings/1/report').to route_to(
        'api/v1/clippings/reports#show',
        clipping_id: '1',
        format: :json
      )
    end
  end
end
