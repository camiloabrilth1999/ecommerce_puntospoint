class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.decimal :price, precision: 10, scale: 2
      t.string :sku
      t.integer :stock
      t.boolean :active
      t.references :administrator, null: false, foreign_key: true

      t.timestamps
    end
    add_index :products, :sku, unique: true
    add_index :products, :name
    add_index :products, :active
  end
end
