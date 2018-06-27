Rails.application.routes.draw do
  
  root 'cafes#index'
  
  resources :posts  # 복수형이여야함 (컨드롤러랑 이름같아야함)
  post 'post/:id/comments/create'  => 'comments#create'
  delete 'comments/:id' => 'comments#destroy'
  # 댓글 만들때는 게시글 아이디도 필요 삭제할때는 댓글아이디만필요
  
  #cafe
  resources :cafes, except: [:destroy] #only: [:--]도 가능
  post '/join_cafe/:cafe_id' => 'cafes#join_cafe', as: 'join_cafe' # as:는 prefix 설정

  # authenticate
  get '/sign_up' => 'authenticate#sign_up'
  post '/sign_up' => 'authenticate#user_sign_up'
  get '/sign_in' => 'authenticate#sign_in'
  post '/sign_in' => 'authenticate#user_sign_in'
  delete '/sign_out' => 'authenticate#sign_out'
  get '/user_info/:user_name' => 'authenticate#user_info'
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
