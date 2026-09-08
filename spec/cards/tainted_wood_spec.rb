require "spec_helper"

RSpec.describe Magic::Cards::TaintedWood do
  include_context "two player game"

  it "taps for colorless mana" do
    land = ResolvePermanent("Tainted Wood", owner: p1)
    p1.activate_ability(ability: land.activated_abilities.first)

    expect(p1.mana_pool[:colorless]).to eq(1)
  end

  it "taps for black or green when you control a Swamp" do
    ResolvePermanent("Swamp", owner: p1)
    land = ResolvePermanent("Tainted Wood", owner: p1)
    p1.activate_ability(ability: land.activated_abilities.last) { _1.choose(:black) }

    expect(p1.mana_pool[:black]).to eq(1)
  end
end