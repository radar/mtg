require 'spec_helper'

RSpec.describe Magic::Cards::AnnexSentry do
  include_context "two player game"

  let(:card) { Card("Annex Sentry") }
  subject(:permanent) { Permanent("Annex Sentry", owner: p1) }
  let(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }
  let(:loxodon_wayfarer) { ResolvePermanent("Loxodon Wayfarer", owner: p2) }

  before do
    game.battlefield.add(permanent)
  end

  it "has toxic 1" do
    expect(subject).to have_keyword(Magic::Cards::Keywords::Toxic)
  end

  it "exiles a target creature or artifact an opponent controls with CMC 3 or less" do
    subject.entered_the_battlefield!
    game.resolve_pending_effect(wood_elves)

    expect(wood_elves.card.zone).to be_exile
    expect(subject.exiled_cards).to include(wood_elves.card)
  end

  it "returns the exiled card when this leaves the battlefield" do
    subject.destroy!
    expect(wood_elves.zone).to be_battlefield
  end
end
