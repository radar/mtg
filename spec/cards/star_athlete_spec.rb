# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StarAthlete do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:athlete) { ResolvePermanent("Star Athlete", owner: p1) }
  let!(:victim) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def attack!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(athlete, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "has menace" do
    expect(athlete).to have_keyword(:menace)
  end

  it "deals 5 damage to the permanent's controller if they don't sacrifice it" do
    attack!
    game.resolve_choice!(target: victim)
    game.skip_choice!
    game.settle!

    expect(p2.life).to eq(15)
    expect(victim.zone).to be_battlefield
  end

  it "has the controller sacrifice the permanent when they choose to" do
    attack!
    game.resolve_choice!(target: victim)
    game.resolve_choice!
    game.settle!

    expect(p2.life).to eq(20)
    expect(victim.zone).to be_nil
  end

  it "can target its controller's own nonland permanent" do
    attack!

    expect(game.choices.last.choices).to include(athlete, victim)
  end

  it "doesn't offer lands" do
    land = ResolvePermanent("Forest", owner: p2)
    attack!

    expect(game.choices.last.choices).not_to include(land)
  end

  it "can be cast with blitz for {3}{R}" do
    card = Card("Star Athlete", owner: p1).tap { p1.hand.add(_1) }
    p1.add_mana(red: 4)
    p1.cast_as(:blitz, card: card) { _1.pay_mana(generic: { red: 3 }, red: 1) }
    game.stack.resolve!
    game.tick!

    expect(p1.permanents.last).to have_keyword(:haste)
  end
end
