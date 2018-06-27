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
  - 

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







### form_for 의 조건

- scaffold를 배우면서 처음 `form_for`를 접하고 잘 이해가 안가는 부분이 많을 것이다. `form_for`를 이해하기 위해서는 기본적으로 model + controller 라는 것을 생각해야 한다. 단순히 form을 만들고 input을 우리가 원하는 이름으로 지정했다면, `form_for`는 model에서 테이블에 설정된 컬럼에 맞춰서 사용한다고 생각해야 한다. input 태그의 타입이 어떤 것이든 상관없다. 하지만 반드시 `form_for` 의 매개변수로 설정된 변수(모델의 인스턴스)와 관련된 모델의 컬럼이 존재해야한다.(*value 속성을 주는 경우는 제외*) 

```ruby
<%= form_for(Cafe.new) do |f| %>
	<%= f.text_field :title %>
    <%= f.text_area :description %>
<% end %>
```

- `Cafe` 모델에 새로운 데이터를 추가하는 `form_for`이다. 아마도 title, description 컬럼을 가지고 있는 것으로 예상할 수 있다.
- `form_for`는 또한 controller 이름, route와도 연관이 있다. `form_for`를 사용할 경우 기본적으로 routes.rb에서 `resources`를 사용한 것으로 간주하고 매개변수로 사용하는 모델의 이름과 관련된 route를 자동으로 만들어 버린다. 만약에 모델명은 `daum`, 컨트롤러명은 `cafe`로 했다면 `form_for`를 사용하는 것이 적절하지 않다.



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

