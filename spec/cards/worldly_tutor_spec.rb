require "spec_helper"

RSpec.describe Magic::Cards::WorldlyTutor do
  include_context "two player game"

  it "puts a creature from the library on top" do
    tutor = Card("Worldly Tutor", owner: p1)
    creature = Card("Grizzly Bears", owner: p1)
    p1.hand.add(tutor)
    p1.library.add(creature)
    p1.add_mana(green: 1)
    p1.cast(card: tutor) { _1.pay_mana(green: 1) }
    game.stack.resolve!
    game.resolve_choice!(target: creature)

    expect(p1.library.first).to eq(creature)
  end
end