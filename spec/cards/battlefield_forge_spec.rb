# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BattlefieldForge do
  include_context "two player game"

  let!(:land) { ResolvePermanent("Battlefield Forge", owner: p1) }

  it "adds {C} without dealing damage" do
    p1.activate_ability(ability: land.activated_abilities.first)
    expect(p1.mana_pool[:colorless]).to eq(1)
    expect(p1.life).to eq(20)
  end

  it "adds {R} or {W} and deals 1 damage to its controller" do
    p1.activate_ability(ability: land.activated_abilities.last) { |a| a.choose(:white) }
    expect(p1.mana_pool[:white]).to eq(1)
    expect(p1.life).to eq(19)
  end
end
