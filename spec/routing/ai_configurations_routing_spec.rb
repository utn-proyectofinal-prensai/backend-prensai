require 'rails_helper'

describe API::V1::AiConfigurationsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/ai_configurations').to route_to('api/v1/ai_configurations#index', format: :json)
    end

    it 'routes to #update via PUT' do
      expect(put: '/api/v1/ai_configurations/1').to route_to('api/v1/ai_configurations#update', key: '1', format: :json)
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/api/v1/ai_configurations/1').to route_to('api/v1/ai_configurations#update', key: '1',
                                                                                                  format: :json)
    end
  end
end
