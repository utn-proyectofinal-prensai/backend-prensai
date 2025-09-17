# frozen_string_literal: true

describe API::V1::UsersController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/users').to route_to('api/v1/users#index', format: :json)
    end

    it 'routes to #show member' do
      expect(get: '/api/v1/user').to route_to('api/v1/users#show', format: :json)
    end

    it 'routes to #show collection' do
      expect(get: '/api/v1/users/1').to route_to('api/v1/users#show', format: :json, id: '1')
    end

    it 'routes to #create' do
      expect(post: '/api/v1/users').to route_to('api/v1/users#create', format: :json)
    end

    it 'routes to #update member' do
      expect(put: '/api/v1/user').to route_to('api/v1/users#update', format: :json)
    end

    it 'routes to #update collection' do
      expect(put: '/api/v1/users/1').to route_to('api/v1/users#update', format: :json, id: '1')
    end

    it 'routes to #destroy collection' do
      expect(delete: '/api/v1/users/1').to route_to('api/v1/users#destroy', format: :json, id: '1')
    end

    it 'routes to #change_password member' do
      expect(patch: '/api/v1/user/change_password').to route_to('api/v1/users#change_password', format: :json)
    end

    it 'routes to #change_password collection' do
      expect(patch: '/api/v1/users/1/change_password').to route_to('api/v1/users#change_password', format: :json,
                                                                                                   id: '1')
    end
  end
end
