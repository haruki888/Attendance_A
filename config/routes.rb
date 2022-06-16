Rails.application.routes.draw do
  root 'static_pages#top' #rootにするとURL/へアクセスした時にトップページが表示されるようになる
  get '/signup', to: 'user#new'
end
