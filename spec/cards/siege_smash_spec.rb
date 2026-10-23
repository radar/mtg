# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SiegeSmash do
  include_context "two player game"

  let(:smash) { Card("Siege Smash", owner: p1).tap { p1.hand.add(_1) } }

  def cast_smash(mode, target)
    p1.add_mana(red: 2)
    p1.cast(card: smash) do |action|
      action.pay_mana(generic: { red: 1 }, red: 1)
      action.choose_mode(mode) { _1.targeting(target) }
    end
  end

  it "destroys target artifact" do
    artifact = ResolvePermanent("Basilisk Collar", owner: p2)
    cast_smash(described_class::DestroyArtifact, artifact)
    game.stack.resolve!
    game.settle!

    expect(p2.graveyard.cards.map(&:name)).to include("Basilisk Collar")
  end

  it "gives target creature +3/+2 and trample until end of turn" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    cast_smash(described_class::Pump, bears)
    game.stack.resolve!
    game.tick!

    expect(bears.power).to eq(5)
    expect(bears.toughness).to eq(4)
    expect(bears.keywords).to include(Magic::Cards::Keywords::TRAMPLE)

    current_turn.end!
    current_turn.cleanup!
    expect(bears.power).to eq(2)
  end

  context "split second" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let(:bolt) { Card("Lightning Bolt", owner: p2).tap { p2.hand.add(_1) } }

    it "stops players casting spells while it is on the stack" do
      cast_smash(described_class::Pump, bears)
      p2.add_mana(red: 1)

      expect do
        p2.cast(card: bolt) { |action| action.pay_mana(red: 1); action.targeting(p1) }
      end.to raise_error(Magic::IllegalAction, /split second/)
    end

    it "allows casting again once it has resolved" do
      cast_smash(described_class::Pump, bears)
      game.stack.resolve!
      p2.add_mana(red: 1)

      expect do
        p2.cast(card: bolt) { |action| action.pay_mana(red: 1); action.targeting(p1) }
      end.not_to raise_error
    end
  end
end
