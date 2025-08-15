class CreateAuditLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :audit_logs do |t|
      t.references :auditable, polymorphic: true, null: false
      t.references :administrator, null: false, foreign_key: true
      t.string :action
      t.text :change_data

      t.timestamps
    end
  end
end
