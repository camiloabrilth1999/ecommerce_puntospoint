class CreateAdministrators < ActiveRecord::Migration[7.2]
  def change
    create_table :administrators do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :role
      t.boolean :active

      t.timestamps
    end
    add_index :administrators, :email, unique: true
  end
end
