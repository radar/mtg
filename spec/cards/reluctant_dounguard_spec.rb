# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ReluctantDounguard do
  include_context "two player game"

  let!(:dounguard) { ResolvePermanent("Reluctant Dounguard", owner: p1) }

  def counters = dounguard.counters.of_type(Magic::Counters::Minus1Minus1).count

  it "enters with two -1/-1 counters, so it is a 2/2" do
    game.tick!

    expect(counters).to eq(2)
    expect([dounguard.power, dounguard.toughness]).to eq([2, 2])
  end

  it "loses a -1/-1 counter whenever another creature you control enters" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.tick!

    expect(counters).to eq(1)
    expect([dounguard.power, dounguard.toughness]).to eq([3, 3])
  end

  it "does not lose one for an opponent's creature" do
    ResolvePermanent("Grizzly Bears", owner: p2)

    expect(counters).to eq(2)
  end

  it "stops once it has no -1/-1 counters" do
    3.times { ResolvePermanent("Grizzly Bears", owner: p1) }
    game.tick!

    expect(counters).to eq(0)
    expect([dounguard.power, dounguard.toughness]).to eq([4, 4])
  end
end
