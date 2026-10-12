# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UneasyPartings do
  include_context "two player game"

  let(:card) { Card("Uneasy Partings", owner: p1) }

  before { p1.hand.add(card) }

  it "lets the owner put the creature on top of their library" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(blue: 4)
    p1.cast(card:) { |a| a.targeting(bears).pay_mana(generic: { blue: 3 }, blue: 1) }
    game.stack.resolve!
    game.resolve_choice!(position: :top)

    expect(game.battlefield.permanents).not_to include(bears)
    expect(p2.library.first).to eq(bears.card)
  end

  it "lets the owner put it on the bottom" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(blue: 4)
    p1.cast(card:) { |a| a.targeting(bears).pay_mana(generic: { blue: 3 }, blue: 1) }
    game.stack.resolve!
    game.resolve_choice!(position: :bottom)

    expect(p2.library.to_a.last).to eq(bears.card)
  end

  it "costs {1} less targeting an attacking nontoken creature" do
    go_to_main_phase_for!(p2)
    attacker = ResolvePermanent("Grizzly Bears", owner: p2)
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    p2.declare_attacker(attacker:, target: p1)
    p1.add_mana(blue: 3)

    p1.cast(card:) { |a| a.targeting(attacker).pay_mana(generic: { blue: 2 }, blue: 1) }

    expect(p1.mana_pool[:blue]).to eq(0)
    expect(game.stack.spells.map(&:card)).to include(card)
  end

  it "has no discount for a non-attacking creature" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(blue: 3)

    expect { p1.cast(card:) { |a| a.targeting(bears).pay_mana(generic: { blue: 2 }, blue: 1) } }.to raise_error(StandardError)
  end
end
