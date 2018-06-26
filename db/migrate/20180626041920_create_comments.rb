class CreateComments < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|
      t.string :content
      t.integer :post_id # 외래키

      t.timestamps
    end
  end
end
