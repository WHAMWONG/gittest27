require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  # Existing routes...
  post '/api/todos/:todo_id/categories', to: 'todos#assign_category', as: 'assign_todo_category'

  # New routes...
  post '/api/todos/:todo_id/attachments', to: 'api/todos#attach_file'

  # Merged new route from new code
  post '/api/todos', to: 'todos#create'
end
