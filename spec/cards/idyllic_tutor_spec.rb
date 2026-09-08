require "spec_helper"

RSpec.describe Magic::Cards::IdyllicTutor do
  include_context "two player game"

  it "searches the library for an enchantment" do
    tutor = Card("Idyllic Tutor", owner: p1)
    target = Card("Spirited Companion", owner: p1)
    p1.hand.add(tutor)
    p1.library.add(target)
    p1.add_mana(white: 3)
    p1.cast(card: tutor) { _1.pay_mana(white: 1, generic: { white: 2 }) }
    game.stack.resolve!

    game.resolve_choice!(targets: [target])

    expect(p1.hand.by_name("Spirited Companion").count).to eq(1)
  end
end