require "spec_helper"

RSpec.describe Magic::Cards::Arachnogenesis do
  include_context "two player game"

  it "creates one Spider for each attacking creature" do
    attacker = ResolvePermanent("Grizzly Bears", owner: p2)
    skip_to_combat!
    p2.declare_attacker(attacker: attacker, target: p1)
    card = Card("Arachnogenesis", owner: p1)
    p1.hand.add(card)
    p1.add_mana(green: 3)
    p1.cast(card: card) { _1.pay_mana(green: 1, generic: { green: 2 }) }
    game.stack.resolve!

    expect(p1.creatures.by_name("Spider").count).to eq(1)
  end
end