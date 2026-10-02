# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VoraciousGreatshark do
  include_context "two player game"

  it "is a 5/4 Shark with flash" do
    shark = ResolvePermanent("Voracious Greatshark", owner: p1)

    expect([shark.power, shark.toughness]).to eq([5, 4])
    expect(shark.card.has_keyword?(:flash)).to eq(true)
  end

  it "counters target creature spell when it enters" do
    go_to_main_phase_for!(p2)
    bears_card = Card("Grizzly Bears", owner: p2)
    p2.add_mana(green: 2)
    p2.cast(card: bears_card) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }

    p1.add_mana(blue: 5)
    p1.cast(card: Card("Voracious Greatshark", owner: p1)) { |a| a.pay_mana(generic: { blue: 3 }, blue: 2) }
    game.stack.resolve! # the Greatshark resolves first; its only legal target is the Bears spell, so it's chosen automatically
    game.settle!

    expect(bears_card.zone).to be_graveyard
  end

  it "can't counter a noncreature, nonartifact spell" do
    go_to_main_phase_for!(p2)
    p2.add_mana(red: 1)
    p2.cast(card: Card("Boltwave", owner: p2)) { |a| a.pay_mana(red: 1) }

    p1.add_mana(blue: 5)
    p1.cast(card: Card("Voracious Greatshark", owner: p1)) { |a| a.pay_mana(generic: { blue: 3 }, blue: 2) }
    game.stack.resolve!
    game.settle!

    expect(game.choices).to be_empty
  end
end
