class CreateIdTokenRequestObjects < ActiveRecord::Migration
  def change
    create_table :id_token_request_objects do |t|
      t.belongs_to :id_token, :request_object
      t.timestamps
    end
  end
end
