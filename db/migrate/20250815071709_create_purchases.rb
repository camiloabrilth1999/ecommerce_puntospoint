class CreatePurchases < ActiveRecord::Migration[7.2]
  def change
    create_table :purchases do |t|
      t.references :product, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true
      t.integer :quantity
      t.decimal :unit_price, precision: 10, scale: 2
      t.decimal :total_amount, precision: 10, scale: 2
      t.datetime :purchase_date
      t.string :status

      t.timestamps
    end

    add_index :purchases, :purchase_date
    add_index :purchases, :status
    add_index :purchases, [:product_id, :purchase_date]
  end
end
