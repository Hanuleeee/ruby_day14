# 20180627_Day13

### 오전과제

- M:N관계의 예시 5가지 이상 적어보기
  - 책, 서점
  - 쇼핑몰, 상품
  - 교수, 학생(수업, 학생)
  - 의사, 환자
  - 상품, 사람
  - 좋아요 게시글
  - 사람, 카페
  - 카테고리, 해쉬태그

  

`rails devise`

> https://github.com/plataformatec/devise
>
> ```bash
> $gem devise
> $ rails generate devise:install
> $ rails generate devise MODEL 
> => 이거 세개만 치면 로그인 창 만들수 있음 But 나중에 자세히 보도록 하자
> ```

### bcrypt

> https://github.com/codahale/bcrypt-ruby

- 그동안 로그인, 회원가입 시에 비밀번호는 일반 문자열로 저장되었었다. 하지만 일반 사이트에서 비밀번호를 평범한 문자열로 저장하는 것은 있을 수 없는 일이다. 간단한 `bcrypt` 잼을 이용하여 비밀번호를 암호화하여 저장하고 로그인 시 복호화하여 사용하는 방법을 배워보자.

*Gemfile*

```ruby
gem 'bcrypt', '~> 3.1.7'   #주석지우기
```

```command
$ bundle install
```

*app/models/user.rb*

```ruby
class User < ApplicationRecord
    has_secure_password    #추가
    has_many :memberships
    has_many :daums, through: :memberships #memberships를 통해서 다음카페를 여러개 가질수있다. 
end
```

  -> `rake db:drop` 후  `rake db:migrate`

- 기본적인 설정은 끝났지만 비밀번호를 받아 암호화하여 저장할 컬럼 설정이 필요하다.

*db/migrate/create_user.rb*

```ruby
class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :user_name
      t.string :password_digest  #추가

      t.timestamps
    end
  end
end
```

- `password_digest` 컬럼은 암호화된 문자열을 저장할 것이다. 우리는 다음과 같은 방식으로 유저 정보를 저장하면 된다.

```ruby
hanullllje:~/daum_cafe (master) $ rails c
Running via Spring preloader in process 15074
Loading development environment (Rails 5.0.7)

2.3.4 :001 > u1= User.create(user_name: "haha", password: "1234")
   (0.1ms)  begin transaction
  SQL (0.5ms)  INSERT INTO "users" ("user_name", "password_digest", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["user_name", "haha"], ["password_digest", "$2a$10$CMsG29R9S7VHwOEYzPMzp.cnv5BxzFT4xiuppgSlLJLINlCEEZS4e"], ["created_at", "2018-06-27 00:57:46.010952"], ["updated_at", "2018-06-27 00:57:46.010952"]]
   (13.3ms)  commit transaction
 => #<User id: 1, user_name: "haha", password_digest: "$2a$10$CMsG29R9S7VHwOEYzPMzp.cnv5BxzFT4xiuppgSlLJL...", created_at: "2018-06-27 00:57:46", updated_at: "2018-06-27 00:57:46"> 
      
      # 결과적으로 암호화된 문자열이 저장될 것이다.
      
2.3.4 :003 > u1.password.eql?("12341234")  
 => false 
2.3.4 :004 > u1.authenticate("1234")     # 비밀번호 일치 시(자동 암호화)
 => #<User id: 1, user_name: "haha", password_digest: "$2a$10$CMsG29R9S7VHwOEYzPMzp.cnv5BxzFT4xiuppgSlLJL...", created_at: "2018-06-27 00:57:46", updated_at: "2018-06-27 00:57:46"> 
2.3.4 :005 > u1.authenticate("12341")    #비밀번호 비일치 시
 => false 
```



### 인증 Controller

```bash
hanullllje:~/daum_cafe (master) $ rails g controller authenticate
hanullllje:~/daum_cafe (master) $ rails g controller cafes
```



- authenticateController 작성

- ApplicationController에서 유저와 관련된 메소드 작성

- CafesController에서 카페와 관련된 메소드 작성

- 각각의 조건에 맞춰서 로직 수정

  

authenticateController작성하면서(method작성)  views 파일 같이작성함

'*app/controllers/authenticate_controller.rb*'



'*app/controllers/application_controller*'

```ruby
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # view에서도 이 method를 사용하기 위해서 추가
  helper_method :user_signed_in?, :current_user
  
  def user_signed_in?
      session[:sign_in_user].present? # T이면 로그인 O
  end
  
  # 로그인되지 않았을 경우에 로그인할 수 있는데로 ..
  def authenticate_user!
      # '/sign_in'을 prefix를 활용해 sign_in_path 로 바꿈
      redirect_to sign_in_path unless user_signed_in
  end
  
  def current_user
      @current_user = User.find(session[:sign_in_user]) if user_signed_in?
  end
end
```

'*views/shared/_nav.html.erb*'  => 수정함



### 카페 만들기

'*routes*'

```ruby
 #cafe
 resources :cafes, except: [:destroy] #only: [:--] 도 가능
```

-> resources 로 route 설정했으므로 `form_for` 사용가능

-> 삭제 method는 만들지 않을것이기때문에 `except:`로 제외



'*app/views/cafes/new.html.erb*'

```erb
<h1>카페 개설하기</h1>
<%= form_for(@cafe, url: cafes_path) do |f| %> <!-- cafe와 관련된 컬럼하나하나가 f에 담겨있음 -->
    <%= f.text_field :title %><br/>
    <%= f.text_area :description %><br/>
    <%= f.submit 'Create Cafe' %>
<% end %>
```

> form_for 을 사용할 수 있는 이유 :
>
> '*routes*'에서 `resources`로 route를 자동설정했기때문에.

> `url: cafes_path` 를 안쓰면 에러가 발생한다.
>
> 왜? 우리 모델 이름은 daum 이라서, 자동으로 daums_path라고 생각하고 거기로 보내준다.
>
> But 우리는 cafes controller을 만들었기때문에 따로  `url: cafes_path`를 지정해준다.



* 하나의 포스트는 하나의 카페와 한명의 유저에 속해있음

'*db/migrate/create_post.rb*'

```ruby
class CreatePosts < ActiveRecord::Migration[5.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :contents
      t.integer :user_id  #추가
      t.integer :daum_id  #추가

      t.timestamps
    end
  end
end
```

*'/app/models/post.rb*'

```ruby
class Post < ApplicationRecord
    has_many :comments 
    belongs_to :user  #추가
    belongs_to :daum  #추가
end
```

'*/app/models/daums*'

```ruby
class Daum < ApplicationRecord
    has_many :memberships
    has_many :users, through: :memberships #memberships를 통해서 유저를 여러개 가질수있다. 
    has_many :posts   #추가
end
```

'*/app/models/use.rb*'

```ruby
class User < ApplicationRecord
    has_secure_password
    has_many :memberships
    has_many :daums, through: :memberships #memberships를 통해서 다음카페를 여러개 가질수있다.
    has_many :posts  #추가
end
```

* cafe와 user을 membership으로 연결

(한 user가 cafe를 만들었지만, cafe_master로 존재할뿐 그 카페에 들어가있지는 않음 그래서 연결) 

```ruby
hanullllje:~/daum_cafe (master) $ rails c
Running via Spring preloader in process 20507
Loading development environment (Rails 5.0.7)
2.3.4 :001 > u1 = User.first
  User Load (0.3ms)  SELECT  "users".* FROM "users" ORDER BY "users"."id" ASC LIMIT ?  [["LIMIT", 1]]
 => #<User id: 1, user_name: "test", password_digest: "$2a$10$gAgYVCCK.6FjXRBmvkdQ1ubdut3WutQST/ipP4pnOEd...", created_at: "2018-06-27 05:15:00", updated_at: "2018-06-27 05:15:00"> 
2.3.4 :002 > d1= Daum.first
  Daum Load (0.2ms)  SELECT  "daums".* FROM "daums" ORDER BY "daums"."id" ASC LIMIT ?  [["LIMIT", 1]]
 => #<Daum id: 1, title: "선풍기 공구", description: "휴대용선풍기공구", master_name: "test3", created_at: "2018-06-27 05:27:50", updated_at: "2018-06-27 05:27:50"> 
2.3.4 :003 > Membership.create(user_id: u1.id, daum_id: d1.id)
   (0.1ms)  begin transaction
  User Load (0.3ms)  SELECT  "users".* FROM "users" WHERE "users"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
  Daum Load (0.2ms)  SELECT  "daums".* FROM "daums" WHERE "daums"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
  SQL (0.5ms)  INSERT INTO "memberships" ("user_id", "daum_id", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["user_id", 1], ["daum_id", 1], ["created_at", "2018-06-27 05:36:11.291656"], ["updated_at", "2018-06-27 05:36:11.291656"]]
   (12.1ms)  commit transaction
 => #<Membership id: 1, user_id: 1, daum_id: 1, created_at: "2018-06-27 05:36:11", updated_at: "2018-06-27 05:36:11"> 
```



- 카페가입 

  cafe_id와 user_id가 필요(어느카페에 누가 가입?)

'*cafes_controller*'

```ruby
 def join_cafe  # 카페가입
     Membership.create(daum_id: params[:cafe_id], user_id:current_user.id)
     redirect_to :back, flash: {success: "카페 가입에 성공했습니다."}
 end
```

'*routes*' 에 추가 (prefix 사용 가능까지)

```ruby
post '/join_cafe/:cafe_id' => 'cafes#join_cafe', as: 'join_cafe'   # as:는 prefix 설정
```



### M:N Relation 설정하기

- 바로 어제 다대다 관계를 설정했는데, 실제 코드에는 적용해보지 않았다. 카페를 개설하는 과정에서 개설한 사람의 user_name이 자동으로 카페의 master_name에 들어가고 해당 유저가 카페에 가입하는 로직을 추가해보자.

*app/controllers/cafes_controller.rb*

```ruby
...
    def create
        @cafe = Daum.new(daum_params)
        @cafe.master_name = current_user.user_name
        if @cafe.save
            Membership.create(daum_id: @cafe.id, user_id: current_user.id)
            redirect_to cafe_path(@cafe), flash: {success: "카페가 개설되었습니다."}
        else
            redirect_to :back, flash: {danger: "카페 개설에 실패했습니다."}
        end
    end
...
```

- *cafe*와 *user*의 관계를 설정하는 *join table*인 *membership* 테이블에 양쪽의 id를 각각 넣어서 관계를 추가한다.  이제 카페를 개설하고 개설한 사람의 이름이 이 카페의 주인 이름으로 저장되고, 자동으로 가입된다. 



### 카페에서 새글쓰기 

: 특정 cafe에서 새글쓰기(`cafes` -> `post/new` -> `posts/create` 까지 연결)

**1. session 이용**

  : `@cafe.id`를 session으로 저장

'*app/controllers/cafes_controller*'

```ruby
def show
  @cafe = Daum.find(params[:id])
  session[:current_cafe] = @cafe.id  # 추가
end
```

'*app/controllers/post_controller*'

 : posts db에는 [title, contents, user_id, daum_id 4개 컬럼이 있다] 

   즉, 하나의 포스트는  title, contents, user_id, daum_id(cafe_id)를 가져야한다!!!!!

```ruby
def create
    @post = Post.new(post_params)
    @post.user_id = current_user.id
    @post.daum_id = session[:current_cafe]  # 추가
    if @post.save
      # flash[:success] = "Post was successfully created."
      redirect_to @post, flash: {success: 'Post was successfully created.'}  # redirect_to:어디로 갈지를 지정, flash의 key: value
    else
      render :new
    end
  end
```



**2  . params** 이용

'*views/cafes/show.html.erb*' 

```erb
<!-- 새글 등록버튼 -->
<%= link_to '새글 쓰기', new_post_path(cafe_id: @cafe.id), class: 'btn btn-info'%>
```

-> `new_post_path` 뒤에 파라미터 추가해서 `cafe_id`를 같이 `new_post_path`로 넘겨줌



'*app/views/posts/_form.html.erb*' (`new.html.erb`의 render)

```erb
<%= form_for(post, html: {class: 'text-center'}) do |f| %> <!-- f는 @post에 담겨있던 컬럼하나하나에 맞춰서 사용가능 -->
  <%= f.hidden_field :daum_id, value: params[:cafe_id] %>  <!-- 추가 -->
  <div class="field">
    <%= f.label :title %>
    <%= f.text_field :title, class: 'form-control' %>
  </div>

  <div class="field">
    <%= f.label :contents %>
    <%= f.text_field :contents, class: 'form-control' %>
  </div>

  <div class="actions">
    <%= f.submit '등록하기', class: 'btn btn-info' %>
    <%= link_to '뒤로가기', posts_path, class: 'btn btn-warning text-white' %>
  </div>
<% end %>
```

-> 원래 `post` db에 ` title, contents, user_id, daum_id `4개 컬럼이 있다.

​    `daum_id`는 *views/cafes/show.html.erb*에서 받아와서 ` f.hidden_field`에 저장

​    나머지는 user에게 입력받는다.

   post가 빈깡통(new)이므로 '*등록하기* '를 누르면 `posts_controller의 create method`로 간다.  



'*app/controllers/posts_controller.rb*'

```ruby
def post_params
    # 우리가 설정해놓은 파라미터만 받을 수 있음
    params.require(:post).permit(:title, :contents, :daum_id) #:daum_id 추가(model에 저장할값)
    # {title: params[:post][:title], contents: params[:post][:contents], daum_id: [:post][:daum_id]}
    end
```



### form_for 의 조건

- scaffold를 배우면서 처음 `form_for`를 접하고 잘 이해가 안가는 부분이 많을 것이다. `form_for`를 이해하기 위해서는 기본적으로 **model + controller** 라는 것을 생각해야 한다. 단순히 form을 만들고 input을 우리가 원하는 이름으로 지정했다면, **`form_for`는 model에서 테이블에 설정된 컬럼에 맞춰서 사용한다고 생각해야 한다**. input 태그의 타입이 어떤 것이든 상관없다. 하지만 반드시 `form_for` 의 매개변수로 설정된 변수(모델의 인스턴스)와 관련된 모델의 컬럼이 존재해야한다.(*value 속성을 주는 경우는 제외*) 

```ruby
<%= form_for(Cafe.new) do |f| %>
	<%= f.text_field :title %>
    <%= f.text_area :description %>
<% end %>
```

- `Cafe` 모델에 새로운 데이터를 추가하는 `form_for`이다. 아마도 title, description 컬럼을 가지고 있는 것으로 예상할 수 있다.

- `form_for`는 또한 controller 이름, route와도 연관이 있다. `form_for`를 사용할 경우 기본적으로 routes.rb에서 `resources`를 사용한 것으로 간주하고 매개변수로 사용하는 모델의 이름과 관련된 route를 자동으로 만들어 버린다. 만약에 모델명은 `daum`, 컨트롤러명은 `cafe`로 했다면 `form_for`를 사용하는 것이 적절하지 않다.

  

### Form_for 정리

- form_tag와 form_for 비교

| **form_tag** | **html**  | **url**   | **method 'get' (default)** |
| ------------ | --------- | --------- | -------------------------- |
|              | **rails** | **url**   | **method 'post'**          |
| **form_for** | **rails** | **model** | **(method 'post')**        |

'*views/posts/_form.html.erb*'

```erb
<%= form_for(post, html: {class: 'text-center'}) do |f| %> <!-- f는 @post에 담겨있던 컬럼하나하나에 맞춰서 사용가능 -->
  <%= f.hidden_field :daum_id, value: params[:cafe_id] %>
  <div class="field">
    <%= f.label :title %>
    <%= f.text_field :title, class: 'form-control' %>
  </div>

  <div class="field">
    <%= f.label :contents %>
    <%= f.text_field :contents, class: 'form-control' %>
  </div>

  <div class="actions">
    <%= f.submit '등록하기', class: 'btn btn-info' %>
    <%= link_to '뒤로가기', posts_path, class: 'btn btn-warning text-white' %>
  </div>
<% end %>
```

- '*views/posts/new.html.erb*'와 '*views/posts/edit.html.erb*' 에서 둘다 `_form.html.erb` 사용

- `posts_controller`의 `new` method는 지금까지 해온 방식(method안에서 `Post.new`를 하지않음)과 다르게 `@post = Post.new`가 필요하다. Why?

- `form_for` 바로 뒤에는 model명이 와야한다. 만약 그 model명에 들어오는 것이 비어있는 값(Post.new)이라면,  `create` method로 가서 유저에게 입력받은 값들을 저장한다.

- 만약 그 model명에 들어오는 값이 `@post = Post.find(params[:id])` 이처럼 find된 값들이 라면, `edit` mothod로 가서 변경된 값들을 저장한다.

- 마지막으로, `form_for`를 사용할때, '*routes*' 에서 `resources`를 사용해서 route를 지정해야한다.

  Ex. `resources :posts`


