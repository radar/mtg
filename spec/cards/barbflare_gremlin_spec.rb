# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BarbflareGremlin do
  include_context "two player game"

  let!(:gremlin) { ResolvePermanent("Barbflare Gremlin", owner: p1) }
  let!(:forest) { ResolvePermanent("Forest", owner: p2) }

  it "has first strike and haste" do
    expect(gremlin).to have_keyword(:first_strike)
    expect(gremlin).to have_keyword(:haste)
  end

  it "does nothing while untapped" do
    p2.activate_ability(ability: forest.activated_abilities.first)

    expect(p2.mana_pool[:green]).to eq(1)
    expect(p2.life).to eq(20)
  end

  context "while tapped" do
    before { gremlin.tap! }

    it "adds one more mana of that type to any player tapping a land and damages them" do
      p2.activate_ability(ability: forest.activated_abilities.first)
      game.settle!

      expect(p2.mana_pool[:green]).to eq(2)
      expect(p2.life).to eq(19)
    end

    it "affects its controller too" do
      mountain = ResolvePermanent("Mountain", owner: p1)
      p1.activate_ability(ability: mountain.activated_abilities.first)
      game.settle!

      expect(p1.mana_pool[:red]).to eq(2)
      expect(p1.life).to eq(19)
    end
  end
end
