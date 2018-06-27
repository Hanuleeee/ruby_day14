class Post < ApplicationRecord
    has_many :comments #메소드처럼쓸수있음
    belongs_to :user
    belongs_to :daum
end
