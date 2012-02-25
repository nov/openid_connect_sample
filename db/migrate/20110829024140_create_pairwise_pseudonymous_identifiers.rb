class CreatePairwisePseudonymousIdentifiers < ActiveRecord::Migration
  def self.up
    create_table :pairwise_pseudonymous_identifiers do |t|
      t.belongs_to :account
      t.string :identifier, :sector_identifier
      t.timestamps
    end
  end

  def self.down
    drop_table :pairwise_pseudonymous_identifiers
  end
end
