class CreatePairwisePseudonymousIdentifiers < ActiveRecord::Migration
  def self.up
    create_table :pairwise_pseudonymous_identifiers do |t|
      t.belongs_to :account, :client
      t.string :identifier
      t.timestamps
    end
  end

  def self.down
    drop_table :pairwise_pseudonymous_identifiers
  end
end
