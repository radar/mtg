# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AshBarrens do
  include_context "two player game"

  it "taps for {C}" do
    barrens = ResolvePermanent("Ash Barrens", owner: p1)
    p1.activate_ability(ability: barrens.activated_abilities.first)

    expect(p1.mana_pool[:colorless]).to eq(1)
  end

  it "has basic landcycling {1}" do
    card = Card("Ash Barrens", owner: p1).tap { p1.hand.add(_1) }
    swamp = Card("Swamp", owner: p1)
    p1.library.add(swamp)
    p1.add_mana(green: 1)
    p1.cycle(card:) { _1.pay_mana(generic: { green: 1 }) }
    game.choices.last.resolve!(targets: [swamp])

    expect(card.zone).to be_graveyard
    expect(swamp.zone).to be_hand
  end
end
