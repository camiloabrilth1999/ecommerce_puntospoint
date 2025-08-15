class CreateClients < ActiveRecord::Migration[7.2]
  def change
    create_table :clients do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.text :address
      t.boolean :active

      t.timestamps
    end
    add_index :clients, :email, unique: true
  end
end
