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

  it "can be cast by sacrificing a nontoken red creature" do
    goblin = ResolvePermanent("Raging Goblin", owner: p1)
    cast_shock_at_p2
    flare = Card("Flare Of Duplication", owner: p1)
    action = cast_action_as(:alternative, card: flare, player: p1)
    expect(action.can_perform?).to eq(true)
    action.pay_cost(goblin)
    action.targeting(game.stack.spells.first)
    action.perform

    expect(goblin.zone).to be_nil
    expect(game.stack.spells.map(&:card)).to include(flare)
  end

  it "cannot sacrifice a nonred creature" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    action = cast_action_as(:alternative, card: Card("Flare Of Duplication", owner: p1), player: p1)

    expect { action.pay_cost(bears) }.to raise_error(RuntimeError, /Invalid creature/)
  end

  it "cannot target a creature spell" do
    p1.add_mana(green: 2)
    p1.cast(card: Card("Grizzly Bears", owner: p1)) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    flare = Card("Flare Of Duplication", owner: p1)

    expect(game.stack.spells.map(&:card).map(&:name)).to eq(["Grizzly Bears"])
    expect(flare.target_choices).to be_empty
  end
end
