require 'spec_helper'

RSpec.describe Magic::Cards::GaleSwooper do
  include_context "two player game"

  subject { Card("Gale Swooper") }
  let!(:wood_elves) { ResolvePermanent("Wood Elves", controller: p1) }

  it "grants wood elves flying" do
    cast_and_resolve(card: subject, player: p1)

    grant_flying = game.next_effect
    expect(grant_flying).to be_a(Magic::Effects::SingleTargetAndResolve)
    game.resolve_pending_effect(wood_elves)
    expect(wood_elves).to be_flying
    expect(wood_elves.keyword_grants.first.until_eot?).to eq(true)
  end
end
