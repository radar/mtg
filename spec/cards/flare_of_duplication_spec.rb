# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FlareOfDuplication do
  include_context "two player game"

  before { go_to_main_phase! }

  def cast_shock_at_p2
    p1.add_mana(red: 1)
    p1.cast(card: Card("Shock", owner: p1)) { |a| a.pay_mana(red: 1).targeting(p2) }
  end

  it "copies target instant, dealing its effect twice" do
    cast_shock_at_p2
    p1.add_mana(red: 3)
    p1.cast(card: Card("Flare Of Duplication", owner: p1)) do |a|
      a.pay_mana(generic: { red: 1 }, red: 2).targeting(game.stack.spells.first)
    end
    game.stack.resolve!
    game.resolve_choice!
    game.resolve_choice!(target: p2)
    game.stack.resolve!

    expect(p2.life).to eq(20 - 4)
  end

  it "has an alternative cost of sacrificing a nontoken red creature" do
    expect(Card("Flare Of Duplication", owner: p1).alternative_cost).to be_a(Magic::Costs::SacrificeCreatureAlternativeCost)
  end

  it "cannot target a creature spell" do
    p1.add_mana(green: 2)
    p1.cast(card: Card("Grizzly Bears", owner: p1)) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    flare = Card("Flare Of Duplication", owner: p1)

    expect(game.stack.spells.map(&:card).map(&:name)).to eq(["Grizzly Bears"])
    expect(flare.target_choices).to be_empty
  end
end
