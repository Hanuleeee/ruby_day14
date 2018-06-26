class Daum < ApplicationRecord
    has_many :memberships
    has_many :users, through: :memberships #memberships를 통해서 유저를 여러개 가질수있다. 
end
