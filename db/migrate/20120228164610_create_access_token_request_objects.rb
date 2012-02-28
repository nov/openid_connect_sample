class CreateAccessTokenRequestObjects < ActiveRecord::Migration
  def change
    create_table :access_token_request_objects do |t|
      t.belongs_to :access_token, :request_object
      t.timestamps
    end
  end
end
