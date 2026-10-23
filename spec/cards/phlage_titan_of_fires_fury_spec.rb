# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PhlageTitanOfFiresFury do
  include_context "two player game"

  let(:card) { Card("Phlage, Titan Of Fire's Fury", owner: p1) }
  let!(:dreadmaw) { ResolvePermanent("Colossal Dreadmaw", owner: p2) }

  before { go_to_main_phase! }

  def cast_normally
    p1.hand.add(card)
    p1.add_mana(red: 2, white: 1)
    p1.cast(card:) { |a| a.pay_mana(generic: { red: 1 }, red: 1, white: 1) }
    game.stack.resolve!
    game.settle!
  end

  def escape
    5.times { p1.graveyard.add(Card("Grizzly Bears", owner: p1)) }
    p1.graveyard.add(card)
    p1.add_mana(red: 2, white: 2)
    exiled = p1.graveyard.cards.reject { _1 == card }
    p1.cast_as(:escape, card:) do |a|
      a.escape_exile(exiled)
      a.pay_mana(red: 2, white: 2)
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a 6/6" do
    phlage = ResolvePermanent("Phlage, Titan Of Fire's Fury", owner: p1)
    game.skip_choice! if game.choices.any?

    expect([phlage.power, phlage.toughness]).to eq([6, 6])
  end

  context "when cast from hand" do
    before { cast_normally }

    it "is sacrificed, after dealing 3 damage and gaining 3 life" do
      game.resolve_choice!(target: p2)
      game.settle!

      expect(p1.creatures.map(&:name)).not_to include("Phlage, Titan of Fire's Fury")
      expect(p1.graveyard.cards.map(&:name)).to include("Phlage, Titan of Fire's Fury")
      expect(p2.life).to eq(17)
      expect(p1.life).to eq(23)
    end
  end

  context "when escaped" do
    before { escape }

    it "stays on the battlefield" do
      game.resolve_choice!(target: p2)
      game.settle!

      expect(p1.creatures.map(&:name)).to include("Phlage, Titan of Fire's Fury")
      expect(p1.graveyard.cards).to be_empty
    end

    it "deals 3 damage to the target and gains 3 life" do
      game.resolve_choice!(target: dreadmaw)
      game.settle!

      expect(dreadmaw.damage).to eq(3)
      expect(p1.life).to eq(23)
    end

    it "deals 3 damage and gains 3 life again whenever it attacks" do
      game.resolve_choice!(target: p2)
      game.settle!
      phlage = p1.creatures.find { _1.name == "Phlage, Titan of Fire's Fury" }
      2.times { game.next_turn }
      skip_to_combat!
      current_turn.declare_attackers!
      p1.declare_attacker(attacker: phlage, target: p2)
      current_turn.attackers_declared!
      game.tick!
      game.settle!

      game.resolve_choice!(target: p2)
      game.settle!

      expect(p2.life).to eq(20 - 3 - 3)
      expect(p1.life).to eq(20 + 3 + 3)
    end
  end

  it "cannot escape without enough cards to exile" do
    p1.graveyard.add(card)
    p1.add_mana(red: 2, white: 2)

    expect do
      p1.cast_as(:escape, card:) do |a|
        a.escape_exile([])
        a.pay_mana(red: 2, white: 2)
      end
    end.to raise_error(ArgumentError, /escape cost/)
  end
end
