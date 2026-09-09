require "spec_helper"

RSpec.describe Magic::Cards::SigilOfTheEmptyThrone do
  include_context "two player game"

  it "creates an Angel when you cast an enchantment" do
    ResolvePermanent("Sigil of The Empty Throne", owner: p1)
    enchantment = Card("Spirited Companion", owner: p1)
    p1.hand.add(enchantment)
    p1.add_mana(white: 2)
    p1.cast(card: enchantment) { _1.pay_mana(white: 1, generic: { white: 1 }) }
    game.stack.resolve!

    expect(p1.creatures.by_name("Angel").count).to eq(1)
  end
end