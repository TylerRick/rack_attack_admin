RackAttackAdmin::Engine.routes.draw do
  root to: 'rack_attack#index'
  get :current_request, to: 'rack_attack#current_request'
  resources :banned_ips, only: [:create, :destroy], id: /.*/
  resources :keys, only: [:destroy], id: /.*/
end if false
