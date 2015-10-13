class CreateCarts < ActiveRecord::Migration
  def change
    create_table :carts do |t|
      t.integer :num_items

      t.timestamps null: false
    end
  end
end
