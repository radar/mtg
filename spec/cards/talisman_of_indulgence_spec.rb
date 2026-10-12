# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TalismanOfIndulgence do
  include_context "two player game"

  let!(:talisman) { ResolvePermanent("Talisman Of Indulgence", owner: p1) }

  it "taps for {C} without damage" do
    p1.activate_ability(ability: talisman.activated_abilities.first)

    expect(p1.mana_pool[:colorless]).to eq(1)
    expect(p1.life).to eq(20)
  end

  it "taps for {B} and deals 1 damage to you" do
    p1.activate_ability(ability: talisman.activated_abilities.last) { _1.choose(:black) }

    expect(p1.mana_pool[:black]).to eq(1)
    expect(p1.life).to eq(19)
  end

  it "taps for {R} and deals 1 damage to you" do
    p1.activate_ability(ability: talisman.activated_abilities.last) { _1.choose(:red) }

    expect(p1.mana_pool[:red]).to eq(1)
    expect(p1.life).to eq(19)
  end
end
