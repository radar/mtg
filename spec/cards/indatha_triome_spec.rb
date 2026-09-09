require "spec_helper"

RSpec.describe Magic::Cards::IndathaTriome do
  include_context "two player game"

  it "enters tapped and taps for white, black, or green" do
    triome = ResolvePermanent("Indatha Triome", owner: p1)
    p1.activate_ability(ability: triome.activated_abilities.first) { _1.choose(:green) }

    expect(triome).to be_tapped
    expect(p1.mana_pool[:green]).to eq(1)
  end
end