require "spec_helper"

RSpec.describe Magic::Cards::EnlightenedTutor do
  include_context "two player game"

  it "puts an artifact or enchantment on top of the library" do
    tutor = Card("Enlightened Tutor", owner: p1)
    target = Card("Mind Stone", owner: p1)
    p1.hand.add(tutor)
    p1.library.add(target)
    p1.add_mana(white: 1)
    p1.cast(card: tutor) { _1.pay_mana(white: 1) }
    game.stack.resolve!
    game.resolve_choice!(target: target)

    expect(p1.library.first).to eq(target)
  end
end