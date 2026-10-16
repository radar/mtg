# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SkoaEmbermage do
  include_context "two player game"

  it "is a legendary 4/4 Goblin Wizard" do
    skoa = ResolvePermanent("Skoa, Embermage", owner: p1)

    expect([skoa.power, skoa.toughness]).to eq([4, 4])
    expect(skoa.card).to be_legendary
    expect(skoa.type?("Goblin")).to be(true)
    expect(skoa.type?("Wizard")).to be(true)
  end

  context "when it enters" do
    it "deals 4 damage to any target: a player" do
      ResolvePermanent("Skoa, Embermage", owner: p1)
      game.resolve_choice!(target: p2)
      game.settle!

      expect(p2.life).to eq(16)
    end

    it "deals 4 damage to any target: a creature" do
      victim = ResolvePermanent("Grizzly Bears", owner: p2)
      ResolvePermanent("Skoa, Embermage", owner: p1)
      game.resolve_choice!(target: victim)
      game.settle!

      expect(victim.card.zone).to be_graveyard
    end
  end

  context "Grandeur" do
    let!(:skoa) do
      ResolvePermanent("Skoa, Embermage", owner: p1).tap { game.resolve_choice!(target: p1) }
    end
    let!(:other_skoa) { Card("Skoa, Embermage", owner: p1).tap { p1.hand.add(_1) } }
    let!(:mountains) { 2.times.map { ResolvePermanent("Mountain", owner: p1) } }
    let(:ability) { skoa.activated_abilities.first }

    def activate(player: p1, discard: other_skoa, sacrifice: mountains, target: p2)
      player.activate_ability(ability: ability) do |action|
        action.targeting(target)
        action.pay_discard(discard)
        action.pay_sacrifice(sacrifice)
      end
    end

    it "discards another Skoa and sacrifices two Mountains to deal 4 damage to any target" do
      activate
      game.stack.resolve!
      game.settle!

      expect(p2.life).to eq(16)
      expect(p1.graveyard.cards).to include(other_skoa)
      expect(p1.lands).to be_empty
    end

    it "can't discard itself" do
      expect { activate(discard: skoa.card) }.to raise_error(RuntimeError, /Invalid target chosen for discard/)
    end

    it "can't discard a card with a different name" do
      other = Card("Grizzly Bears", owner: p1).tap { p1.hand.add(_1) }

      expect { activate(discard: other) }.to raise_error(RuntimeError, /Invalid target chosen for discard/)
    end

    it "needs two Mountains, not other lands" do
      forest = ResolvePermanent("Forest", owner: p1)

      expect { activate(sacrifice: [mountains.first, forest]) }.to raise_error(RuntimeError, /Sacrifice exactly two/)
    end

    it "has no activated ability while in hand" do
      expect(other_skoa.zone).to be_hand
      expect(other_skoa.hand_abilities).to be_empty
    end

    it "can't be activated by the opponent" do
      expect { activate(player: p2) }.to raise_error(Magic::IllegalAction, /does not control/)

      expect(p1.hand.cards).to include(other_skoa)
      expect(p1.lands.count).to eq(2)
      expect(p2.life).to eq(20)
    end
  end
end
