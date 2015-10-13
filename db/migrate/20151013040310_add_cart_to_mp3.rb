class AddCartToMp3 < ActiveRecord::Migration
  def change
    add_reference :mp3s, :cart, index: true, foreign_key: true
  end
end
