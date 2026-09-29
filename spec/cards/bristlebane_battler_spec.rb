# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BristlebaneBattler do
  include_context "two player game"

  let!(:battler) { ResolvePermanent("Bristlebane Battler", owner: p1) }

  def counters = battler.counters.of_type(Magic::Counters::Minus1Minus1).count

  it "has trample" do
    expect(battler).to be_trample
  end

  it "enters with five -1/-1 counters, so it is a 1/1" do
    game.tick!

    expect(counters).to eq(5)
    expect([battler.power, battler.toughness]).to eq([1, 1])
  end

  it "loses a -1/-1 counter whenever another creature you control enters" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.tick!

    expect(counters).to eq(4)
    expect([battler.power, battler.toughness]).to eq([2, 2])
  end

  it "ignores creatures an opponent controls" do
    ResolvePermanent("Grizzly Bears", owner: p2)

    expect(counters).to eq(5)
  end
end
