class User < ApplicationRecord
    has_secure_password
    has_many :memberships
    has_many :daums, through: :memberships #memberships를 통해서 다음카페를 여러개 가질수있다.
    has_many :posts
end
