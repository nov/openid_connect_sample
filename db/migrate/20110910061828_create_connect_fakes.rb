class CreateConnectFakes < ActiveRecord::Migration
  def self.up
    create_table :connect_fakes do |t|
      t.belongs_to :account
      t.timestamps
    end
  end

  def self.down
    drop_table :connect_fakes
  end
end
