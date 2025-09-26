# frozen_string_literal: true

describe API::V1::HealthController do
  describe 'routing' do
    it 'routes to #status' do
      expect(get: '/api/v1/status').to route_to('api/v1/health#status', format: :json)
    end
  end
end
