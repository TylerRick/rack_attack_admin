RackAttackAdmin::Engine.routes.draw do
  namespace :admin do
    get :rack_attack, to: 'rack_attack#index'
    namespace :rack_attack do
      get :current_request, to: 'rack_attack#current_request'
      resources :banned_ips, only: [:create, :destroy], id: /.*/
      resources :keys, only: [:destroy], id: /.*/
    end
  end
end
