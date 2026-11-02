# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RidersOfTheMark do
  include_context "two player game"
  before { go_to_main_phase! }

  def soldiers(player) = player.creatures.select { _1.token? && _1.type?("Soldier") }

  def end_step(player = p1)
    game.notify!(Magic::Events::BeginningOfEndStep.new(active_player: player))
    game.settle!
  end

  def attack_with(creature)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(creature, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  describe "stats" do
    let!(:riders) { ResolvePermanent("Riders Of The Mark", owner: p1) }

    it "is a 7/4 Human Knight with trample and haste" do
      expect([riders.power, riders.toughness]).to eq([7, 4])
      expect(riders.type?("Human")).to be(true)
      expect(riders.type?("Knight")).to be(true)
      expect(riders).to be_trample
      expect(riders).to be_haste
    end
  end

  describe "affinity for Humans" do
    let(:card) { Card("Riders Of The Mark", owner: p1) }

    it "costs {6}{R} with no Humans" do
      expect(card.mana_value).to eq(7)
      expect(card.cost.generic).to eq(6)
      expect(card.cost.cost[:red]).to eq(1)
    end

    it "costs {1} less for each Human you control" do
      ResolvePermanent("Protector Of Gondor", owner: p1)
      ResolvePermanent("Grizzly Bears", owner: p1)
      game.tick!
      p1.add_mana(red: 1, colorless: 4)
      p1.cast(card: card) { |a| a.pay_mana(red: 1, generic: { colorless: 4 }) }
      game.stack.resolve!
      expect(p1.creatures.map(&:name)).to include("Riders of the Mark")
    end

    it "does not count an opponent's Humans" do
      ResolvePermanent("Protector Of Gondor", owner: p2)
      game.tick!
      p1.add_mana(red: 1, colorless: 5)
      expect do
        p1.cast(card: card) { |a| a.pay_mana(red: 1, generic: { colorless: 5 }) }
      end.to raise_error(StandardError)
    end
  end

  describe "end step trigger" do
    let!(:riders) { ResolvePermanent("Riders Of The Mark", owner: p1) }

    it "returns it to hand and creates tokens equal to its toughness if it attacked" do
      attack_with(riders)
      end_step

      expect(p1.hand.cards).to include(riders.card)
      expect(p1.creatures).not_to include(riders)
      expect(soldiers(p1).count).to eq(4)
    end

    it "uses its toughness as it last was, including bonuses" do
      riders.modify_toughness(2, until_eot: true)
      game.tick!
      attack_with(riders)
      end_step

      expect(soldiers(p1).count).to eq(6)
    end

    it "does nothing if it did not attack" do
      end_step

      expect(p1.creatures).to include(riders)
      expect(soldiers(p1)).to be_empty
      expect(game.choices).to be_empty
    end

    it "does nothing on the opponent's end step" do
      attack_with(riders)
      end_step(p2)

      expect(p1.creatures).to include(riders)
      expect(soldiers(p1)).to be_empty
    end

    it "creates no tokens if it left the battlefield before the trigger resolved" do
      attack_with(riders)
      game.notify!(Magic::Events::BeginningOfEndStep.new(active_player: p1))
      riders.destroy!
      game.settle!

      expect(soldiers(p1)).to be_empty
      expect(p1.graveyard.cards).to include(riders.card)
      expect(p1.hand.cards).not_to include(riders.card)
    end
  end
end
