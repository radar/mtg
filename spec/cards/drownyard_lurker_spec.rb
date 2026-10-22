# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DrownyardLurker do
  include_context "two player game"

  def spawns = p1.creatures.select { _1.name == "Eldrazi Spawn" }

  it "is a 7/7 Eldrazi Trilobite with vigilance" do
    lurker = ResolvePermanent("Drownyard Lurker", owner: p1)

    expect([lurker.power, lurker.toughness]).to eq([7, 7])
    expect(lurker).to have_keyword(:vigilance)
  end

  it "creates an Eldrazi Spawn when cast" do
    go_to_main_phase!
    lurker = Card("Drownyard Lurker", owner: p1)
    p1.hand.add(lurker)
    p1.add_mana(colorless: 7)
    p1.cast(card: lurker) { |a| a.pay_mana(generic: { colorless: 7 }) }
    game.settle!
    game.stack.resolve!

    expect(spawns.count).to eq(1)
    game.stack.resolve!
    game.settle!
    expect(lurker.zone).to eq(game.battlefield)
  end

  it "creates an Eldrazi Spawn and draws a card when cycled" do
    lurker = Card("Drownyard Lurker", owner: p1)
    p1.hand.add(lurker)
    p1.add_mana(blue: 3)
    hand_size = p1.hand.count
    p1.cycle(card: lurker) { |a| a.pay_mana(generic: { blue: 2 }, blue: 1) }
    game.settle!

    expect(lurker.zone).to be_graveyard
    expect(spawns.count).to eq(1)
    expect(p1.hand.count).to eq(hand_size)
  end
end
