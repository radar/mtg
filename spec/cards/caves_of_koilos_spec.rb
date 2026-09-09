require "spec_helper"

RSpec.describe Magic::Cards::CavesOfKoilos do
  include_context "two player game"

  it "taps for colorless without life loss" do
    land = ResolvePermanent("Caves of Koilos", owner: p1)
    p1.activate_ability(ability: land.activated_abilities.first)

    expect(p1.mana_pool[:colorless]).to eq(1)
    expect(p1.life).to eq(20)
  end

  it "taps for white and costs 1 life" do
    land = ResolvePermanent("Caves of Koilos", owner: p1)
    p1.activate_ability(ability: land.activated_abilities.last) { _1.choose(:white) }

    expect(p1.mana_pool[:white]).to eq(1)
    expect(p1.life).to eq(19)
  end
end