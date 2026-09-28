# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ExplosiveProdigy do
  include_context "two player game"
  before { go_to_main_phase! }

  it "deals damage equal to the number of colors among permanents you control to a creature an opponent controls" do
    ResolvePermanent("Alaborn Trooper", owner: p1)
    victim = ResolvePermanent("Grizzly Bears", owner: p2)
    card = Card("Explosive Prodigy", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: 2)
    cast_and_resolve(card: card, player: p1) { |a| a.pay_mana(generic: { red: 1 }, red: 1) }

    # The only legal target is chosen automatically.
    # Alaborn Trooper (W) + Explosive Prodigy (R) = 2 damage
    expect(victim.damage).to eq(2)
  end

  it "does nothing when the opponent controls no creatures" do
    card = Card("Explosive Prodigy", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: 2)
    cast_and_resolve(card: card, player: p1) { |a| a.pay_mana(generic: { red: 1 }, red: 1) }

    expect(game.choices).to be_empty
  end
end
