# 20180628_Day14

### Fat Model, Skinny Controller

- 레일즈에서는 컨트롤러보다 모델에서 많은 로직을 구현하고 컨트롤러에서는 그 로직을 가져다 사용하는 방식으로 구현하는 것을 추천하고 있다. 우리도 우리가 구현한 많은 로직들을 모델로 옮길 수 있다. ' *현재 로그인 한 유저가 이 카페에 가입한 유저인가?* ' 를 먼저 컨트롤러에서 구현했다가 모델로 옮겨보도록 하겠다.

- 카페 가입 중복 막기

  **이 카페에 현재 로그인된 사용자가 가입이 됐는지 확인**

  * 이전 코드로는 중복가입을 막을 수 없다.

  1.  가입버튼을 안보이게 한다. (사용자 화면 조작) ->  Model 코딩(메서드)
  2. 중복 가입 체크 후 진행 (서버에서 로직조작) -> Model Validation (가입되어있다면 조인테이블을 안만들어준다.)

*app/controllers/cafes_controller.rb*

```ruby
   def join_cafe
      #사용자가 가입하려는 카페
      cafe = Daum.find(params[:cafe_id])
      if cafe.users.include? current_user  
         redirect_to :back, flash: {danger: "카페 가입에 실패했습니다. 이미 가입한 카페 입니다."}
      else
         Membership.create(daum_id: params[:cafe_id], user_id: current_user.id)
         redirect_to cafe_path(cafe), flash: {success: "카페 가입에 성공했습니다."}
      end
  end
```

- `cafe.users.include? current_user` 는 **현재 유저가 이 카페에 가입되어 있는지 확인하는 로직**이다. 메소드 체이닝을 통해서 코드는 한줄에 구현했지만 직관적인 내용은 아닌것 같다. 이 코드를 `is_member?` 라고 하는 메소드를 구현해서 조건문의 조건으로 활용해보자.

```ruby
def 메소드명(매개변수)
  Logic
end
```

- 위와같은 방식으로 메소드를 만들 수 있다. 인스턴스 메소드와 클래스 메소드의 차이는 다음과 같다.

```ruby
# 클래스 메소드
def self.method_name
  # self를 사용할 수 없다.
end

# 인스턴스 메소드
def method_name
  # self를 사용할 수 있다.
end
```

- 클래스 메소드의 경우 `Model.method_name` 의 형태로 사용할 수 있고, 인스턴스 메소드는 `instance.method_name` 의 형태로 사용할 수 있다. 우리에게 필요한 메소드는 `Daum` 모델의 하나의 인스턴스에서 사용할 메소드 이다.

*app/models/daum.rb*

```ruby
class Daum < ApplicationRecord
    has_many :memberships
    has_many :users, through: :memberships #memberships를 통해서 유저를 여러개 가질수있다. 
    has_many :posts
    
    def is_member?(user) #매개변수로 받음
        self.users.include?(user)  #daum.users.include? 인데, 여기서 daum이 self니까
    end
end
```

*app/controllers/cafes_controller.rb*

```ruby
...
  def join_member
    cafe = Daum.find(params[:cafe_id])
    if cafe.is_member? current_user   # 사용자설정 메소드
      redirect_to :back, flash: {danger: "카페 가입에 실패했습니다. 이미 가입한 카페 입니다."}
    else
      Membership.create(daum_id: params[:cafe_id], user_id: current_user.id)
      redirect_to cafe_path(cafe), flash: {success: "카페 가입에 성공했습니다."}
    end
  end
...
```

- 다음과 같은 형태로 바꾸어 사용할 수 있다.



### Model Validation

- 모델에서는 메소드를 만드는 것 이외에 **DB에 저장될 데이터에 대해서 유효성 검사를 실행할 수 있다**. 유효성 검사는 사용자가 사용하는 페이지 뿐만 아니라 서버에서도 검증해야하는 부분이다. 우리는 우선 서버에서의 유효성 검사에 대해 알아보자.
- 레일즈에서는 많은 유효성 검사를 지원한다. 간단한 코드 한줄로 유효성 검사를 실행할 수 있다.

*app/models/user.rb*

```ruby
class User < ApplicationRecord
    validates :user_name, uniqueness: true
    # user_name 컬럼에 unique 속성 부여
  ...
end
```

- 모델에 다음과 같은 코드를 추가하는 것만으로 `user_name` 컬럼에 중복값이 없도록 검사할 수 있다.

> 자세한 정보는 [이 주소를](http://guides.rubyonrails.org/active_record_validations.html) 참고! (2.11 uniqueness )



### File Upload

- 게시판의 기능을 완성하기 위해서 이미지 업로드, 즉 파일 업로드 기능을 지원해야한다. 기본적으로 `<input type="file">` 을 통해 파일 선택창을 구현할 수는 있지만 실제로 서버에서 해당 파일을 받아서 저장할 수 없다. 그래서 Carrierwave 라고 하는 잼을 이용해서 파일 업로드를 구현하도록 한다.

> https://github.com/carrierwaveuploader/carrierwave#carrierwave

*Gemfile*

```ruby
...
  gem 'carrierwave'
...
```

```command
$ bundle install
$ rails g uploader Image
```

-> '*app/uploaders/image_uploader.rb*' 생성된다.



- Carrierwave를 설치하지 않은 경우에는 generate uploader 명령어가 실행되지 않는다.

*app/uploaders/image_uploader.rb*

```ruby
class ImageUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process resize_to_fit: [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_whitelist
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
end

```

- 이제 이 만들어진 파일을 우리가 사용할 모델의 컬럼에 mount 시켜주면 된다.

*app/models/post.rb*

```ruby
class Post < ApplicationRecord
    mount_uploader :image_path, ImageUploader   # 추가
    
    has_many :comments #메소드처럼쓸수있음
    belongs_to :user
    belongs_to :daum
end
```

-> 서버 시작한후 사진 upload하면 '*public/uploads/post/image_path*'에서 이미지 확인가능



- 이미지를 저장할 image_path 컬럼을 추가한다.

'*/db/migrate/_create_posts.rb*'

```ruby
...
      t.string :image_path # 추가
...
```

- 이는 우리가 추가한 image_path라는 컬럼에 ImageUploader를 연결한 것을 의미한다.

*app/controllers/posts_controller.rb*

```ruby
...
    def post_params
      params.require(:post).permit(:title, :contents, :image_path, :daum_id) # image_path 추가 
        # 우리가 설정해놓은 파라미터만 받을 수 있음
    end 
...
```

*app/views/posts/_form.html.erb*

```erb
...
  <div class="field">
    <%= f.label :image_path %>
    <%= f.file_field :image_path, class: 'form-control' %>
  </div>
...
```

- 다음과 같이 추가 후 서버를 시작하면 파일이 직접 업로드 되고 이 파일은 `public/uploads/post/image_path` 폴더로 업로드 된다.

*app/views/posts/show.html.erb*

```erb
...
<p>
  <strong>ImagePath:</strong>
  <img src="<%= @post.image_path %>" width="100%" />
</p>
...
```

- 이미지를 서버에 뿌려주기 위해서 `img tag`를 추가한다. 다음과 같은 형식으로 업로드된 이미지를 볼 수 있다.



### Image Versioning

- 이미지 업로드에 제한을 두지 않으면 많은 사람들이 고화질, 고용량의 이미지를 업로드 하게되고, 이러한 이미지는 우리 서버 혹은 저장소에 무리를 주게된다. 또한 사용자의 페이지 로딩 속도도 현격하게 떨어져 서비스의 사용성을 저하시킨다. 이러한 이유로 이미지를 업로드 할 때, 여러개의 버전을 만들어 저장해놓고 필요한 모양에 따라 사용하게 된다. 예를 들어, 썸네일과 같은 부분은 이미지 버전을 만들어두고 필요에 따라 사용하게된다.

*Gemfile*

```ruby
gem 'mini_magick'
```

```command
$ bundle install
$ sudo apt-get update
$ sudo apt-get install -y imagemagick # ubuntu
$ brew install imagemagick # macOs
$ sudo yum install -y imagemagick #centOS
```

- 이미지를 리사이즈 하기 위해서는 imagemagick 프로그램을 설치하고 이용해야 한다.

*app/uploaders/image_uploader.rb*

```ruby
...
  version :thumb_fit do
    process resize_to_fit: [250, 250]
  end
  
  version :thumb_fill do
    process resize_to_fill: [250, 250]
  end
...
```

- version 블록을 통해  version의 이름을 설정할 수 있다.

> `resize_to_fit`: 가로, 세로 중 긴 쪽을 기준으로 이미지 사이즈를 비율에 맞게 축소한다.
>
> `resize_to_fill`: 이미지를 정해진 사이즈에 맞춰 크롭한다. 이미지의 중앙을 중심으로 사이즈에 맞게 크롭된다.

*app/views/posts/show.html.erb*

```erb
...
<p>
  <strong>Thumb Fill:</strong>
  <img src="<%= @post.image_path.thumb_fill.url %>" />
</p>
<p>
  <strong>Thumb Fit:</strong>
  <img src="<%= @post.image_path.thumb_fit.url %>" />
</p>
...
```

- 버전에 맞게 작성된 이미지를 볼 수 있다.



### Upload to AWS S3

- 우리 서버에 이미지를 계속해서 저장하다보면 우리 서버 크기에 따라 제한이 생길 수 있다. 하여 **외부 저장소를 따로 두고 해당 저장소에서 파일의 주소를 받아 사용**하게 된다.
- 구현에 크게 어려움은 없으나 ***SECRET KEY*** 를 잘 관리해야 한다.

> https://github.com/carrierwaveuploader/carrierwave#carrierwave  'fog'검색



'*Gemfile*'

```ruby
gem 'fog-aws'   #추가
```

'*config/initializers*'에 *fog.rb* 새 파일 생성 -> 이 파일을 통해 인증

* 환경변수 따로 설정안해주고 .. `figaro`를 사용한다.



'*Gemfile*'

```ruby
# credential
gem 'figaro'
```

```bash
hanullllje:~/daum_cafe (master) $ bundle install
hanullllje:~/daum_cafe (master) $ bundle exec figaro install  
 # ->config/application.yml 파일 생성됨
```

'*config/application.yml*'

```yaml
AWS_ACCESS_KEY_ID: aws id 
AWS_SECRET_ACCESS_KEY: aws password 
```



* `initialize`: 서버시작할 때 모든 파일 다 읽어들이고 시작