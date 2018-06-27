class CreateDaums < ActiveRecord::Migration[5.0]
  def change
    create_table :daums do |t|
      
      t.string :title
      t.text :description
      t.string :master_name # 카페만든 주인

      t.timestamps
    end
  end
end
