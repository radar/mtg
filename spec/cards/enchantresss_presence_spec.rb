require "spec_helper"

RSpec.describe Magic::Cards::EnchantresssPresence do
  include_context "two player game"

  it "draws a card when you cast an enchantment" do
    ResolvePermanent("Enchantress's Presence", owner: p1)
    enchantment = Card("Spirited Companion", owner: p1)
    p1.hand.add(enchantment)
    p1.add_mana(white: 2)
    hand_size = p1.hand.count
    p1.cast(card: enchantment) { _1.pay_mana(white: 1, generic: { white: 1 }) }
    game.stack.resolve!

    expect(p1.hand.count).to eq(hand_size + 1)
  end
end