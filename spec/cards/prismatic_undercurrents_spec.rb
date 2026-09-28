# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PrismaticUndercurrents do
  include_context "two player game"

  before do
    go_to_main_phase!
    4.times { p1.library.add(Card("Forest")) }
  end

  it "lets you play an additional land each turn" do
    ResolvePermanent("Prismatic Undercurrents", owner: p1)
    expect(p1.max_lands_per_turn).to eq(2)
  end

  it "searches for up to X basic lands, X being the colors among your permanents" do
    ResolvePermanent("Alaborn Trooper", owner: p1)
    card = Card("Prismatic Undercurrents", owner: p1)
    p1.hand.add(card)
    p1.add_mana(green: 4)
    p1.cast(card: card) { |a| a.pay_mana(green: 1, generic: { green: 3 }) }
    game.stack.resolve!

    choice = game.choices.first
    expect(choice).not_to be_nil
    lands = p1.library.basic_lands.first(2)
    choice.resolve!(targets: lands)

    expect(p1.hand.cards).to include(*lands) # white + green = 2
  end
end
