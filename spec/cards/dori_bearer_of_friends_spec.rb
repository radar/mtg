# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DoriBearerOfFriends do
  include_context "two player game"

  it "is a 3/2 Dwarf Warrior with trample" do
    dori = ResolvePermanent("Dori, Bearer Of Friends", owner: p1)

    expect(dori.card.types).to include("Dwarf", "Warrior")
    expect([dori.power, dori.toughness]).to eq([3, 2])
    expect(dori.trample?).to be(true)
  end

  it "creates a Treasure token when it enters" do
    ResolvePermanent("Dori, Bearer Of Friends", owner: p1)

    expect(p1.permanents.select { |permanent| permanent.name == "Treasure" }.count).to eq(1)
  end
end
