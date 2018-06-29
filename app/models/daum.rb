class Daum < ApplicationRecord
    has_many :memberships
    has_many :users, through: :memberships #memberships를 통해서 유저를 여러개 가질수있다. 
    has_many :posts
    
    # def self.메소드명 -> 클래스 메소드
    #     로직안에서 self를 쓸 수 없음
    # end
    
    # def 메소드명 -> 인스턴스 메소드
    #     로직안에서 self를 쓸 수 있음
    # end
    
    def is_member?(user) #매개변수로 받음
        self.users.include?(user)  #daum.users.include? 인데, 여기서 daum이 self니까
        
    end
end
