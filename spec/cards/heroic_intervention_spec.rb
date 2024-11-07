require 'spec_helper'

RSpec.describe Magic::Cards::HeroicIntervention do
  include_context "two player game"

  before do
    ResolvePermanent("Island", owner: p1)
    ResolvePermanent("Wood Elves", owner: p1)
    ResolvePermanent("Sol Ring", owner: p1)
    ResolvePermanent("Selfless Savior", owner: p2)
  end

  subject { Card("Heroic Intervention", owner: p1) }

  it "all permanents you control gain hexproof and indestructible" do
    cast_and_resolve(card: subject)
    game.tick!

    island = p1.permanents.by_name("Island").first
    wood_elves = p1.permanents.by_name("Wood Elves").first
    sol_ring = p1.permanents.by_name("Sol Ring").first

    [island, wood_elves, sol_ring].each do |permanent|
      expect(permanent.hexproof?).to eq(true)
      expect(permanent.indestructible?).to eq(true)
    end
  end
end
