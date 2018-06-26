class Comment < ApplicationRecord
    # 1:m에서 m이 comment
    belongs_to :post
end
