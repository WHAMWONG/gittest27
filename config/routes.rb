
require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  # No changes required for '/api/todos/:todo_id/categories' as it is already defined
  # Existing routes...
  post '/api/todos/:todo_id/categories', to: 'todos#assign_category', as: 'assign_todo_category'
  post '/api/todos', to: 'todos#create'

  # New routes...
  post '/api/todos/:todo_id/attachments', to: 'api/todos#attach_file'
end
