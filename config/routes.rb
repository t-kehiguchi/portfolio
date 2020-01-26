Rails.application.routes.draw do
  root   'static_pages#top'
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
end
