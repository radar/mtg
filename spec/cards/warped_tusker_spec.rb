# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WarpedTusker do
  include_context "two player game"

  def spawns = p1.creatures.select { _1.name == "Eldrazi Spawn" }

  it "is a 6/8 Eldrazi Boar Beast with reach" do
    tusker = ResolvePermanent("Warped Tusker", owner: p1)

    expect([tusker.power, tusker.toughness]).to eq([6, 8])
    expect(tusker).to have_keyword(:reach)
  end

  it "creates an Eldrazi Spawn when cast" do
    go_to_main_phase!
    tusker = Card("Warped Tusker", owner: p1)
    p1.hand.add(tusker)
    p1.add_mana(colorless: 7)
    p1.cast(card: tusker) { |a| a.pay_mana(generic: { colorless: 7 }) }
    game.settle!
    game.stack.resolve!

    expect(spawns.count).to eq(1)
    game.stack.resolve!
    game.settle!
    expect(tusker.zone).to eq(game.battlefield)
  end

  it "creates an Eldrazi Spawn and draws a card when cycled" do
    tusker = Card("Warped Tusker", owner: p1)
    p1.hand.add(tusker)
    p1.add_mana(green: 3)
    hand_size = p1.hand.count
    p1.cycle(card: tusker) { |a| a.pay_mana(generic: { green: 2 }, green: 1) }
    game.settle!

    expect(tusker.zone).to be_graveyard
    expect(spawns.count).to eq(1)
    expect(p1.hand.count).to eq(hand_size)
  end
end
