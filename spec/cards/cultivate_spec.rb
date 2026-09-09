require "spec_helper"

RSpec.describe Magic::Cards::Cultivate do
  include_context "two player game"

  it "searches for basic lands" do
    card = Card("Cultivate", owner: p1)
    forest = Card("Forest", owner: p1)
    plains = Card("Plains", owner: p1)
    p1.hand.add(card)
    p1.library.add(forest)
    p1.library.add(plains)
    p1.add_mana(green: 3)
    p1.cast(card: card) { _1.pay_mana(green: 1, generic: { green: 2 }) }
    game.stack.resolve!
    game.resolve_choice!(targets: [forest, plains])

    expect(p1.lands.by_name("Forest").count).to eq(1)
    expect(p1.hand.by_name("Plains").count).to eq(1)
  end
end