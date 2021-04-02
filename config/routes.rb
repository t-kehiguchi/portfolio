Rails.application.routes.draw do
  root   'static_pages#top'
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  get    'users' , to: 'users#index', as: 'users'
  get    'users/filter/:id', to: 'users#index', as: 'user_filter'
  delete 'users/:id' , to: 'users#destroy', as: 'user_delete'
  get    'users/new' , to: 'users#new'
  post   'users/new' , to: 'users#new', as: 'user_new'
  get    'users/:id/edit' , to: 'users#edit', as: 'users_edit'
  post   'users/edit' , to: 'users#edit', as: 'user_edit'
  get    'users/confirm' , to: 'users#confirm'
  post   'users/confirm' , to: 'users#confirm', as: 'user_confirm'
  get    'users/:id/detail' , to: 'users#detail', as: 'user_detail'
  get    'users/search' , to: 'users#search'
  post   'users/search',  to: 'users#search', as: 'user_search'
  get    'projects' , to: 'projects#index', as: 'projects'
  get    'projects/new' , to: 'projects#new'
  post   'projects/new' , to: 'projects#new', as: 'project_new'
  get    'projects/:id/edit' , to: 'projects#edit', as: 'projects_edit'
  post   'projects/edit' , to: 'projects#edit', as: 'project_edit'
  get    'projects/confirm' , to: 'projects#confirm'
  post   'projects/confirm' , to: 'projects#confirm', as: 'project_confirm'
  get    'projects/:id/detail' , to: 'projects#detail', as: 'project_detail'
  get    'projects/search' , to: 'projects#search'
  post   'projects/search',  to: 'projects#search', as: 'project_search'
  get    'projects/:id/matching' , to: 'projects#matching', as: 'project_matching'
  namespace 'api' do
    namespace 'v1' do
      post   'users/search',  to: 'users#search', as: 'user_search'
      post   'projects/search',  to: 'projects#search', as: 'project_search'
    end
  end
end
