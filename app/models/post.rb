class Post < ApplicationRecord
    mount_uploader :image_path, ImageUploader # :컬럼명지정, 
    #mount_uploader :file_path, FileUploader # 다른 일반파일을 올리고싶을때는 이런식으로 사용
    
    has_many :comments #메소드처럼쓸수있음
    belongs_to :user
    belongs_to :daum
end
