require "spec_helper"

RSpec.describe Magic::Cards::BeseechTheMirror do
  include_context "two player game"

  it "searches the library for a card" do
    spell = Card("Beseech The Mirror", owner: p1)
    target = Card("Mind Stone", owner: p1)
    p1.hand.add(spell)
    p1.library.add(target)
    p1.add_mana(black: 4)
    p1.cast(card: spell) { _1.pay_mana(black: 3, generic: { black: 1 }) }
    game.stack.resolve!
    game.resolve_choice!(target: target)

    expect(p1.hand.by_name("Mind Stone").count).to eq(1)
  end
end