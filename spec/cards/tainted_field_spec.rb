require "spec_helper"

RSpec.describe Magic::Cards::TaintedField do
  include_context "two player game"

  it "taps for colorless mana" do
    land = ResolvePermanent("Tainted Field", owner: p1)
    p1.activate_ability(ability: land.activated_abilities.first)

    expect(p1.mana_pool[:colorless]).to eq(1)
  end

  it "taps for white or black with a Swamp" do
    ResolvePermanent("Swamp", owner: p1)
    land = ResolvePermanent("Tainted Field", owner: p1)
    p1.activate_ability(ability: land.activated_abilities.last) { _1.choose(:white) }

    expect(p1.mana_pool[:white]).to eq(1)
  end
end