# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AdultGoldDragon do
  include_context "two player game"

  let!(:dragon) { ResolvePermanent("Adult Gold Dragon", owner: p1) }

  it "is a 4/3 dragon creature" do
    expect(dragon.card.types).to include("Creature", "Dragon")
    expect(dragon.power).to eq(4)
    expect(dragon.toughness).to eq(3)
  end

  it "has flying, lifelink and haste" do
    expect(dragon.flying?).to eq(true)
    expect(dragon.lifelink?).to eq(true)
    expect(dragon.haste?).to eq(true)
  end

  it "costs {3}{R}{W}" do
    expect(dragon.card.cost.generic).to eq(3)
    expect(dragon.card.cost.red).to eq(1)
    expect(dragon.card.cost.white).to eq(1)
  end
end
