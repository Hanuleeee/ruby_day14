# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# 다른데서 만들어진 csv 파일등등을 우리 db에 넣음
10.times do
 post = Post.create(title: Faker::Overwatch.quote, contents: Faker::Lorem.paragraph)
 5.times do
     post.comments.create(content: Faker::Lorem.question) # post.comments에 자동으로 post_id가 들어감
 end
end