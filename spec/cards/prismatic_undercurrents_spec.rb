# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PrismaticUndercurrents do
  include_context "two player game"

  before do
    go_to_main_phase!
    4.times { p1.library.add(Card("Forest")) }
  end

  def cast_undercurrents
    card = Card("Prismatic Undercurrents", owner: p1)
    p1.hand.add(card)
    p1.add_mana(green: 4)
    p1.cast(card: card) { |a| a.pay_mana(green: 1, generic: { green: 3 }) }
    game.stack.resolve!
    game.choices.first
  end

  it "lets you play an additional land each turn" do
    ResolvePermanent("Prismatic Undercurrents", owner: p1)
    expect(p1.max_lands_per_turn).to eq(2)
  end

  it "searches for up to X basic lands, X being the colors among your permanents" do
    ResolvePermanent("Alaborn Trooper", owner: p1)
    choice = cast_undercurrents

    expect(choice.upto).to eq(2) # white + green
    lands = p1.library.basic_lands.first(2)
    choice.resolve!(targets: lands)

    expect(p1.hand.cards).to include(*lands)
  end

  it "caps the search at X" do
    choice = cast_undercurrents

    expect(choice.upto).to eq(1) # the enchantment itself is the only color (green)
    lands = p1.library.basic_lands.first(3)

    expect { choice.resolve!(targets: lands) }.to raise_error(ArgumentError)
  end
end
