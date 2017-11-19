Rails.application.routes.draw do

  resources :comments
  resources :microposts
  get '/feed' => 'microposts#index'

  get 'pages/index'
  root :to => 'pages#index'

  resources :sessions, :only => [:new, :create, :destroy]
  get '/signin' => 'sessions#new'
  get '/signout' => 'sessions#destroy'

  resources :users
  get '/signup' => 'users#new'
  get '/user_feed' => 'users#feed'
  # get '/follow' => 'users#following'
  get '/follow' => 'users#follow'
  get '/unfollow' => 'users#unfollow'

  get '/like' => 'microposts#create_like'
  get '/like_comment' => 'microposts#create_comment_like'

  resources :users do
    member do
      get :following, :followers
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
