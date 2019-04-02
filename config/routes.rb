puts __FILE__
RackAttackAdmin::Engine.routes.draw do
  root to: 'application#test'
end
