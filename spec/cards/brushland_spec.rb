require "spec_helper"

RSpec.describe Magic::Cards::Brushland do
  include_context "two player game"

  it "taps for colorless without life loss" do
    land = ResolvePermanent("Brushland", owner: p1)
    p1.activate_ability(ability: land.activated_abilities.first)

    expect(p1.mana_pool[:colorless]).to eq(1)
    expect(p1.life).to eq(20)
  end
end