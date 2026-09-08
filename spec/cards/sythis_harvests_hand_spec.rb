require "spec_helper"

RSpec.describe Magic::Cards::SythisHarvestsHand do
  include_context "two player game"

  it "gains life when you cast an enchantment" do
    ResolvePermanent("Sythis, Harvest's Hand", owner: p1)
    enchantment = Card("Spirited Companion", owner: p1)
    p1.hand.add(enchantment)
    p1.add_mana(white: 2)
    p1.cast(card: enchantment) { _1.pay_mana(white: 1, generic: { white: 1 }) }
    game.stack.resolve!

    expect(p1.life).to eq(21)
  end
end