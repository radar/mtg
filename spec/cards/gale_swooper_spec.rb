require 'spec_helper'

RSpec.describe Magic::Cards::GaleSwooper do
  include_context "two player game"

  subject { Card("Gale Swooper") }
  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

  it "grants wood elves flying" do
    cast_and_resolve(card: subject, player: p1)

    game.resolve_choice!(target: wood_elves)
    game.tick!

    expect(wood_elves).to be_flying
    expect(wood_elves.keyword_grant_modifiers.first.until_eot?).to eq(true)
  end
end
