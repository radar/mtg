require 'spec_helper'

RSpec.describe Magic::Cards::WardedBattlements do
  include_context "two player game"

  subject!(:warded_battlements) { ResolvePermanent("Warded Battlements", owner: p1) }
  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

  before do

  end

  it "has defender" do
    expect(subject.defender?).to eq(true)
  end

  it "boosts power of attacking creatures" do
    skip_to_combat!
    current_turn.declare_attackers!

    current_turn.declare_attacker(
      wood_elves,
      target: p2,
    )

    expect(wood_elves.power).to eq(2)
    expect(wood_elves.toughness).to eq(1)
  end
end
