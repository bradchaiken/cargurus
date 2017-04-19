Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get  'index',  to: 'search#index'
  post 'search', to: 'search#search'
  get  'result', to: 'search#result'
  root 'home#index'
end
