# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ReiteratingBolt do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:bolt) { Card("Reiterating Bolt", owner: p1).tap { p1.hand.add(_1) } }
  let!(:ogre) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def cast_bolt(target, replicate: nil)
    p1.add_mana(red: 2)
    p1.cast(card: bolt) do |action|
      action.pay_mana(red: 1, generic: { red: 1 })
      action.replicate(replicate) if replicate
      action.targeting(target)
    end
  end

  it "deals 3 damage to target creature" do
    cast_bolt(ogre)
    game.stack.resolve!
    game.settle!

    expect(p2.graveyard.cards.map(&:name)).to eq(["Grizzly Bears"])
  end

  it "cannot target a player" do
    p1.add_mana(red: 2)
    expect do
      p1.cast(card: bolt) do |action|
        action.pay_mana(red: 1, generic: { red: 1 })
        action.targeting(p2)
      end
    end.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  context "replicate" do
    it "pays {E}{E}{E} per replicate and copies the spell" do
      p1.add_counter("energy", amount: 6)
      other = ResolvePermanent("Grizzly Bears", owner: p2)
      cast_bolt(ogre, replicate: 2)
      game.skip_choice! # keep the target for the copies
      game.settle!

      expect(p1.energy).to eq(0)
      expect(p2.graveyard.cards.map(&:name)).to eq(["Grizzly Bears"])
      expect(other.damage).to eq(0)
    end

    it "lets the copy choose a new target" do
      p1.add_counter("energy", amount: 3)
      other = ResolvePermanent("Grizzly Bears", owner: p2)
      cast_bolt(ogre, replicate: 1)
      game.resolve_choice! # choose new targets
      game.resolve_choice!(target: other)
      game.settle!

      expect(p2.graveyard.cards.map(&:name)).to eq(["Grizzly Bears", "Grizzly Bears"])
    end

    it "cannot replicate without enough energy" do
      p1.add_counter("energy", amount: 2)
      expect { cast_bolt(ogre, replicate: 1) }.to raise_error(/cannot pay for replicate/)
    end
  end
end
