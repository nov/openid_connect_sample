class CreateClients < ActiveRecord::Migration
  def self.up
    create_table :clients do |t|
      t.belongs_to :account
      t.string(
        :identifier,
        :secret,
        :name,
        :logo_url,
        :token_endpoint_auth_type,
        :policy_url,
        :jwk_url,
        :jwk_encryption_url,
        :x509_url,
        :x509_encryption_url,
        :sector_identifier,
        :request_object_signing_alg,
        :contacts,
        :redirect_uris,
        :userinfo_signed_response_alg,
        :userinfo_encrypted_response_alg,
        :id_token_signed_response_alg,
        :id_token_encrypted_response_alg
      )
      t.boolean :dynamic, :native, :ppid, default: false
      t.datetime :expires_at
      t.timestamps
    end
    add_index :clients, :identifier, unique: true
  end

  def self.down
    drop_table :clients
  end
end

