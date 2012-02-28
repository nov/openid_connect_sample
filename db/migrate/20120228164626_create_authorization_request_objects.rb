class CreateAuthorizationRequestObjects < ActiveRecord::Migration
  def change
    create_table :authorization_request_objects do |t|
      t.belongs_to :authorization, :request_object
      t.timestamps
    end
  end
end
