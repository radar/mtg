require 'spec_helper'

RSpec.describe Magic::Cards::GaleSwooper do
  include_context "two player game"

  subject { Card("Gale Swooper", controller: p1) }
  let(:wood_elves) { Card("Wood Elves", controller: p1) }

  let(:green_card) { double(Magic::Card, colors: [:green] )}

  before do
    game.battlefield.add(wood_elves)
  end

  it "grants wood elves flying" do
    subject.cast!
    game.stack.resolve!
    grant_flying = game.next_effect
    expect(grant_flying).to be_a(Magic::Effects::SingleTargetAndResolve)
    game.resolve_pending_effect(wood_elves)
    expect(wood_elves).to be_flying
    expect(wood_elves.keyword_grants.first.until_eot?).to eq(true)
  end
end
