# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EldraziRavager do
  include_context "two player game"
  before { go_to_main_phase! }

  def attack(creature)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: creature, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.tick!
  end

  it "is a 6/6 Eldrazi" do
    ravager = ResolvePermanent("Eldrazi Ravager", owner: p1)

    expect([ravager.power, ravager.toughness]).to eq([6, 6])
    expect(ravager.type?("Eldrazi")).to eq(true)
  end

  it "has annihilator 1" do
    ravager = ResolvePermanent("Eldrazi Ravager", owner: p1)
    2.times { ResolvePermanent("Grizzly Bears", owner: p2) }

    attack(ravager)
    game.skip_choice!
    game.settle!

    expect(p2.permanents.size).to eq(1)
  end

  describe "from the graveyard" do
    let(:card) { Card("Eldrazi Ravager", owner: p1) }
    let!(:eldrazi) { 2.times.map { ResolvePermanent("Eldrazi Repurposer", owner: p1) } }

    before { p1.graveyard.add(card) }

    def activate(sacrificed)
      p1.activate_ability(ability: card.graveyard_abilities.first) { |a| a.pay_sacrifice(sacrificed) }
      game.stack.resolve!
      game.settle!
    end

    it "returns to hand by sacrificing two Eldrazi" do
      expect(card.zone).to be_graveyard
      activate(eldrazi)

      expect(card.zone).to be_hand
      expect(eldrazi.map(&:zone)).to all(be_nil)
    end

    it "rejects one Eldrazi, a non-Eldrazi, or the same Eldrazi twice" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      ability = card.graveyard_abilities.first

      [[eldrazi.first], [eldrazi.first, bears], [eldrazi.first, eldrazi.first]].each do |payment|
        expect { p1.activate_ability(ability: ability) { |a| a.pay_sacrifice(payment) } }.to raise_error(ArgumentError)
      end
      expect(card.zone).to be_graveyard
      expect(eldrazi.map(&:zone)).to all(be_battlefield)
    end

    it "cannot be activated with fewer than two Eldrazi" do
      eldrazi.first.sacrifice!
      expect { p1.activate_ability(ability: card.graveyard_abilities.first) { |a| a.pay_sacrifice(eldrazi) } }
        .to raise_error(StandardError)
      expect(card.zone).to be_graveyard
    end

    it "is not available from hand" do
      card.move_to_hand!(p1)
      expect { activate(eldrazi) }.to raise_error(StandardError)
    end
  end

  describe "cycling {2}" do
    it "discards it and draws a card" do
      ravager = Card("Eldrazi Ravager", owner: p1)
      p1.hand.add(ravager)
      p1.add_mana(colorless: 2)
      hand = p1.hand.count

      p1.cycle(card: ravager) { |a| a.pay_mana(generic: { colorless: 2 }) }
      game.settle!

      expect(ravager.zone).to be_graveyard
      expect(p1.hand.count).to eq(hand)
    end
  end
end
