# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WornPowerstone do
  include_context "two player game"

  before { go_to_main_phase! }

  it "enters tapped" do
    stone = Card("Worn Powerstone", owner: p1)
    p1.hand.add(stone)
    p1.add_mana(colorless: 3)
    p1.cast(card: stone) { |a| a.pay_mana(generic: { colorless: 3 }) }
    game.stack.resolve!

    permanent = p1.permanents.find { _1.name == "Worn Powerstone" }
    expect(permanent).to be_tapped
  end

  it "taps for two colorless mana" do
    stone = ResolvePermanent("Worn Powerstone", owner: p1)
    stone.untap!
    p1.activate_ability(ability: stone.activated_abilities.first)

    expect(p1.mana_pool[:colorless]).to eq(2)
    expect(stone).to be_tapped
  end
end
