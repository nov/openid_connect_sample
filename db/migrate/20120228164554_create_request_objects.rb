class CreateRequestObjects < ActiveRecord::Migration
  def change
    create_table :request_objects do |t|
      t.text :jwt_string
      t.timestamps
    end
  end
end
