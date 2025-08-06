Rails.application.routes.draw do
  # API routes
  namespace :api do
    # Test routes (temporales)
    get '/test', to: 'test#index'
    get '/test/news', to: 'test#news'
    get '/test/stats', to: 'test#stats'
    post '/test/login', to: 'test#login_test'
    
    # Auth routes
    post '/auth/login', to: 'users#login'
    post '/auth/logout', to: 'users#logout'
    get '/auth/me', to: 'users#me'
    
    # Dashboard routes
    get '/dashboard/stats', to: 'dashboard#stats'
    get '/dashboard/latest-news', to: 'dashboard#latest_news'
    get '/dashboard/active-events', to: 'dashboard#active_events'
    get '/dashboard/active-mentions', to: 'dashboard#active_mentions'
    
    # Upload routes
    post '/upload/preview', to: 'upload#preview'
    post '/upload/news', to: 'upload#news'
    post '/upload/links', to: 'upload#links'
    
    # News routes
    get '/news', to: 'news#index'
    get '/news/stats', to: 'news#stats'
    get '/news/:id', to: 'news#show'
    post '/news/import', to: 'news#import'
    post '/news/metrics', to: 'news#metrics'
    
    # Mentions routes
    get '/mentions/active', to: 'mentions#active'
    put '/mentions/active', to: 'mentions#update_active'
    get '/mentions/all', to: 'mentions#index'
    post '/mentions', to: 'mentions#create'
    put '/mentions/:id', to: 'mentions#update'
    delete '/mentions/:id', to: 'mentions#destroy'
    
    # Events routes
    get '/events', to: 'events#index'
    get '/events/active', to: 'events#active'
    post '/events', to: 'events#create'
    put '/events/:id', to: 'events#update'
    delete '/events/:id', to: 'events#destroy'
  end
end