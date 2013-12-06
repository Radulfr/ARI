Hello::Application.routes.draw do
  get "hello/index"
  root 'hello#index'
  
  post '/hello/index', to: 'hello#index'
  get '/hello/download', to: 'hello#download'

end
