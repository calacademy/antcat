FactoryBot.define do
  # TODO default to "waiting" -- nay, "approved" -- because that's the new deal.
  factory :taxon_state do
    review_state TaxonState::OLD
    deleted 0
  end
end
