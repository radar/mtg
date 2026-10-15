# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DesertedTemple do
  include_context "two player game"

  let!(:temple) { ResolvePermanent("Deserted Temple", owner: p1) }
  let!(:forest) { ResolvePermanent("Forest", owner: p1) }

  it "taps for {C}" do
    p1.activate_ability(ability: temple.activated_abilities.first)

    expect(p1.mana_pool[:colorless]).to eq(1)
    expect(temple).to be_tapped
  end

  it "untaps target land for {1}, {T}" do
    forest.tap!
    p1.add_mana(green: 1)
    p1.activate_ability(ability: temple.activated_abilities[1]) do
      _1.pay_mana(generic: { green: 1 })
      _1.targeting(forest)
    end
    game.stack.resolve!

    expect(forest).to be_untapped
    expect(temple).to be_tapped
  end
end
