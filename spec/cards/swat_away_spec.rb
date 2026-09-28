# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SwatAway do
  include_context "two player game"

  let(:card) { Card("Swat Away", owner: p1) }

  it "lets the owner of a target creature put it on top of their library" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(blue: 4)
    p1.hand.add(card)

    p1.cast(card:) { |a| a.pay_mana(generic: { blue: 2 }, blue: 2).targeting(bears) }
    game.stack.resolve!
    game.resolve_choice!(position: :top)

    expect(game.battlefield.permanents).not_to include(bears)
    expect(p2.library.first).to eq(bears.card)
    expect(bears.card.zone).to eq(p2.library)
  end

  it "lets the owner put it on the bottom of their library" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(blue: 4)
    p1.hand.add(card)

    p1.cast(card:) { |a| a.pay_mana(generic: { blue: 2 }, blue: 2).targeting(bears) }
    game.stack.resolve!
    game.resolve_choice!(position: :bottom)

    expect(p2.library.to_a.last).to eq(bears.card)
  end

  it "can target a spell, removing it from the stack without countering it" do
    go_to_main_phase_for!(p2)
    creature = Card("Grizzly Bears", owner: p2)
    p2.hand.add(creature)
    p2.add_mana(green: 2)
    p2.cast(card: creature) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    spell = game.stack.spells.first
    p1.add_mana(blue: 4)
    p1.hand.add(card)

    p1.cast(card:) { |a| a.pay_mana(generic: { blue: 2 }, blue: 2).targeting(spell) }
    game.stack.resolve!
    game.resolve_choice!(position: :top)

    expect(game.stack.spells).to be_empty
    expect(p2.library.first).to eq(creature)
    expect(p2.graveyard).not_to include(creature)
  end

  it "costs {2} less if a creature is attacking you" do
    go_to_main_phase_for!(p2)
    attacker = ResolvePermanent("Grizzly Bears", owner: p2)
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    p2.declare_attacker(attacker:, target: p1)
    other = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(blue: 2)
    p1.hand.add(card)

    p1.cast(card:) { |a| a.pay_mana(blue: 2).targeting(other) }

    expect(p1.mana_pool[:blue]).to eq(0)
    expect(game.stack.spells.map(&:card)).to include(card)
  end

  it "does not get the discount when nothing is attacking you" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(blue: 2)
    p1.hand.add(card)

    expect { p1.cast(card:) { |a| a.pay_mana(blue: 2).targeting(bears) } }.to raise_error(StandardError)
  end
end
