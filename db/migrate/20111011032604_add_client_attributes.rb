class AddClientAttributes < ActiveRecord::Migration
  def self.up
    change_table :clients do |t|
      t.string   :contact, :logo_url, :js_origin_uri, :jwk_url, :x509_url, :sector_identifier
      t.boolean  :native, default: false
      t.datetime :expires_at
    end
  end

  def self.down
  end
end
