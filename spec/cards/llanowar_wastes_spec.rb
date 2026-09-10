# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LlanowarWastes do
  include_context "two player game"

  let!(:wastes) { ResolvePermanent("Llanowar Wastes", owner: p1) }

  it "adds {C} without dealing damage" do
    p1.activate_ability(ability: wastes.activated_abilities.first)
    expect(p1.mana_pool[:colorless]).to eq(1)
    expect(p1.life).to eq(20)
  end

  it "adds {B} or {G} and deals 1 damage to its controller" do
    p1.activate_ability(ability: wastes.activated_abilities.last) { |a| a.choose(:black) }
    expect(p1.mana_pool[:black]).to eq(1)
    expect(p1.life).to eq(19)
  end
end
