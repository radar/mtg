# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RaggedShortSpear do
  include_context "two player game"

  before { go_to_main_phase! }

  def cast_spear
    card = Card("Ragged Short Spear", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: 2)
    p1.cast(card:) { |a| a.pay_mana(generic: { red: 1 }, red: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "may discard a card to draw two cards when it enters" do
    cast_spear
    hand_before = p1.hand.count
    game.resolve_choice!
    game.resolve_choice!(card: p1.hand.cards.first)

    expect(p1.hand.count).to eq(hand_before + 1)
    expect(p1.graveyard.count).to eq(1)
  end

  it "does nothing if you decline" do
    cast_spear
    hand_before = p1.hand.count
    game.skip_choice!

    expect(p1.hand.count).to eq(hand_before)
  end

  it "gives equipped creature +2/+0" do
    spear = ResolvePermanent("Ragged Short Spear", owner: p1)
    game.skip_choice! while game.choices.any?
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(colorless: 3)
    p1.activate_ability(ability: spear.activated_abilities.first) { |a| a.pay_mana(generic: { colorless: 3 }).targeting(bear) }
    game.stack.resolve!
    game.tick!

    expect([bear.power, bear.toughness]).to eq([4, 2])
  end
end
