class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :identifier
      t.datetime :last_logged_in_at
      t.timestamps
    end
    add_index :accounts, :identifier, unique: true
  end

  def self.down
    drop_table :accounts
  end
end
