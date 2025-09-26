# frozen_string_literal: true

describe API::V1::SettingsController do
  describe 'routing' do
    it 'routes to #must_update' do
      expect(get: '/api/v1/settings/must_update').to route_to('api/v1/settings#must_update', format: :json)
    end
  end
end
