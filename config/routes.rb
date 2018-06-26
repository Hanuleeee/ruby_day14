Rails.application.routes.draw do
  
  post 'post/:id/comments/create'  => 'comments#create'
  delete 'comments/:id' => 'comments#destroy'
  # 댓글 만들때는 게시글 아이디도 필요 삭제할때는 댓글아이디만필요

  get 'comments/destroy'

  root 'posts#index'
  resources :posts  # 복수형이여야함 (컨드롤러랑 이름같아야함)
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
