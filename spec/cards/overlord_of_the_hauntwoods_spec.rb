# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OverlordOfTheHauntwoods do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:card) { Card("Overlord Of The Hauntwoods", owner: p1).tap { p1.hand.add(_1) } }

  def everywhere = p1.permanents.select { _1.name == "Everywhere" }

  it "is a 6/5 Avatar Horror enchantment creature" do
    p1.add_mana(green: 5)
    p1.cast(card: card) { _1.pay_mana(generic: { green: 3 }, green: 2) }
    game.stack.resolve!
    game.settle!

    permanent = p1.permanents.find { _1.card == card }
    expect([permanent.power, permanent.toughness]).to eq([6, 5])
  end

  it "creates a tapped colorless land token named Everywhere that is every basic land type" do
    p1.add_mana(green: 3)
    p1.cast_as(:impending, card: card) { _1.pay_mana(generic: { green: 1 }, green: 2) }
    game.stack.resolve!
    game.settle!

    land = everywhere.first
    expect(land).to be_tapped
    expect(land.colors).to be_empty
    expect(land).to be_land
    expect(%w[Plains Island Swamp Mountain Forest].all? { land.type?(_1) }).to be(true)
  end

  it "taps for any of the five colors once untapped" do
    ResolvePermanent("Overlord Of The Hauntwoods", owner: p1)
    game.settle!
    land = everywhere.first
    land.untap!
    game.tick!

    colors = land.activated_abilities.flat_map(&:choices).uniq
    expect(colors).to contain_exactly(:white, :blue, :black, :red, :green)
  end
end
