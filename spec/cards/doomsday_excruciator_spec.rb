# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DoomsdayExcruciator do
  include_context "two player game"

  it "is a 6/6 flying Demon" do
    demon = ResolvePermanent("Doomsday Excruciator", owner: p1)

    expect(demon.power).to eq(6)
    expect(demon.toughness).to eq(6)
    expect(demon).to be_flying
    expect(demon.card.types).to include("Demon")
  end

  it "exiles all but the bottom six cards of each library when cast" do
    go_to_main_phase!
    p1.add_mana(black: 6)
    demon = Card("Doomsday Excruciator", owner: p1)
    p1.hand.add(demon)
    p1.cast(card: demon) { |a| a.pay_mana(black: 6) }
    game.stack.resolve!
    game.settle!

    expect(p1.library.count).to eq(6)
    expect(p2.library.count).to eq(6)
    expect(game.exile.count).to be >= 1
  end

  it "does nothing when it enters without being cast" do
    before = p2.library.count
    ResolvePermanent("Doomsday Excruciator", owner: p1, cast: false)
    game.settle!

    expect(p2.library.count).to eq(before)
  end

  it "draws a card at the beginning of your upkeep" do
    ResolvePermanent("Doomsday Excruciator", owner: p1)
    2.times { game.next_turn }
    hand = p1.hand.count
    go_to_main_phase!
    game.settle!

    # one from the draw step, one from the upkeep trigger
    expect(p1.hand.count).to eq(hand + 2)
  end
end
