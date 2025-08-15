class RemoveAuditLogsTable < ActiveRecord::Migration[7.2]
  def up
    drop_table :audit_logs
  end

  def down
    create_table :audit_logs do |t|
      t.string :auditable_type, null: false
      t.bigint :auditable_id, null: false
      t.bigint :administrator_id, null: false
      t.string :action
      t.text :change_data

      t.timestamps null: false
    end

    add_index :audit_logs, [ :auditable_type, :auditable_id ], name: "index_audit_logs_on_auditable"
    add_index :audit_logs, :administrator_id

    add_foreign_key :audit_logs, :administrators
  end
end
