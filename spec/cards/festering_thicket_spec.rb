require "spec_helper"

RSpec.describe Magic::Cards::FesteringThicket do
  include_context "two player game"

  it "enters tapped and produces black or green" do
    land = ResolvePermanent("Festering Thicket", owner: p1)
    p1.activate_ability(ability: land.activated_abilities.first) { _1.choose(:green) }

    expect(land).to be_tapped
    expect(p1.mana_pool[:green]).to eq(1)
  end
end