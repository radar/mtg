# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AetherRevolt do
  include_context "two player game"

  let!(:revolt) { ResolvePermanent("Aether Revolt", owner: p1) }
  let!(:enemy) { ResolvePermanent("Serra Angel", owner: p2) }
  let!(:ally) { ResolvePermanent("Serra Angel", owner: p1) }

  def bolt!(target)
    p1.add_mana(red: 1)
    action = cast_action(player: p1, card: Card("Lightning Bolt", owner: p1))
    action.pay_mana(red: 1)
    action.targeting(target)
    game.take_action(action)
    game.stack.resolve!
    game.settle!
  end

  def revolt_now!
    token = ResolvePermanent("Grizzly Bears", owner: p1)
    token.destroy!
    game.settle!
  end

  context "without revolt" do
    it "adds no damage to an opponent" do
      bolt!(p2)
      expect(p2.life).to eq(17)
    end
  end

  context "with revolt" do
    before { revolt_now! }

    it "adds 2 noncombat damage to an opponent" do
      bolt!(p2)
      expect(p2.life).to eq(15)
    end

    it "adds 2 noncombat damage to an opponent's permanent" do
      bolt!(enemy)
      expect(enemy.damage).to eq(5)
    end

    it "does not add damage to you or your permanents" do
      bolt!(p1)
      expect(p1.life).to eq(17)
      bolt!(ally)
      expect(ally.damage).to eq(3)
    end

    it "stops applying at the next turn" do
      game.next_turn
      game.next_turn
      bolt!(p2)
      expect(p2.life).to eq(17)
    end
  end

  context "when a permanent left under the opponent's control only" do
    it "does not count as revolt" do
      enemy.destroy!
      game.settle!
      bolt!(p2)
      expect(p2.life).to eq(17)
    end
  end

  context "when you get energy" do
    it "deals that much damage to any target" do
      ResolvePermanent("Amped Raptor", owner: p1)
      expect(game.choices.first).to be_a(described_class::EnergyTrigger::TargetChoice)
      game.resolve_choice!(target: p2)
      game.settle!
      expect(p2.life).to eq(18)
    end

    it "adds the revolt bonus to its own damage" do
      revolt_now!
      ResolvePermanent("Amped Raptor", owner: p1)
      game.resolve_choice!(target: p2)
      game.settle!
      expect(p2.life).to eq(16)
    end

    it "does not trigger when the opponent gets energy" do
      game.add_effect(Magic::Effects::AddCounterToPlayer.new(source: revolt, player: p2, counter_type: "energy", amount: 2, target: p2))
      game.settle!
      expect(game.choices).to be_empty
    end

    it "does not trigger for other counters" do
      game.add_effect(Magic::Effects::AddCounterToPlayer.new(source: revolt, player: p1, counter_type: "poison", amount: 1, target: p1))
      game.settle!
      expect(game.choices).to be_empty
    end
  end
end
