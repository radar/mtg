# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DoranBesiegedByTime do
  include_context "two player game"

  let!(:doran) { ResolvePermanent("Doran, Besieged By Time", owner: p1) }

  context "creature spells with toughness greater than power" do
    before { go_to_main_phase! }

    it "cost {1} less" do
      card = Card("Courser Of Kruphix", owner: p1) # {1}{G}{G}, 2/4
      p1.add_mana(green: 2)
      p1.hand.add(card)

      p1.cast(card:) { |a| a.pay_mana(green: 2) }
      game.stack.resolve!

      expect(p1.creatures.map(&:name)).to include("Courser of Kruphix")
    end

    it "do not get the discount when power is at least toughness" do
      card = Card("Grizzly Bears", owner: p1) # {1}{G}, 2/2
      p1.add_mana(green: 1)
      p1.hand.add(card)

      expect { p1.cast(card:) { |a| a.pay_mana(green: 1) } }.to raise_error(StandardError)
    end

    it "do not get the discount for an opponent's spells" do
      go_to_main_phase_for!(p2)
      card = Card("Courser Of Kruphix", owner: p2)
      p2.add_mana(green: 2)
      p2.hand.add(card)

      expect { p2.cast(card:) { |a| a.pay_mana(green: 2) } }.to raise_error(StandardError)
    end
  end

  it "gives +X/+X to a creature you control when it attacks, X being the difference between power and toughness" do
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: doran, target: p2)
    current_turn.attackers_declared!
    game.settle!

    expect(doran.power).to eq(5)
    expect(doran.toughness).to eq(10)
  end

  it "gives +X/+X to a creature you control when it blocks" do
    go_to_main_phase_for!(p2)
    attacker = ResolvePermanent("Grizzly Bears", owner: p2)
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    p2.declare_attacker(attacker:, target: p1)
    current_turn.attackers_declared!
    current_turn.declare_blocker(doran, attacker:)
    game.settle!

    expect(doran.power).to eq(5)
    expect(doran.toughness).to eq(10)
  end

  it "does not trigger for an opponent's attacking creature" do
    go_to_main_phase_for!(p2)
    attacker = ResolvePermanent("Courser Of Kruphix", owner: p2)
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    p2.declare_attacker(attacker:, target: p1)
    current_turn.attackers_declared!
    game.settle!

    expect(attacker.power).to eq(2)
  end
end
