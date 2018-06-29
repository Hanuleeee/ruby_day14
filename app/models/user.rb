class User < ApplicationRecord
    has_secure_password
     # user_name 컬럼에 unique 속성 부여
    validates :user_name, uniqueness: true
    validates :password_digest, presence: true #빈값허용안함
    
    has_many :memberships
    has_many :daums, through: :memberships #memberships를 통해서 다음카페를 여러개 가질수있다.
    has_many :posts
end
