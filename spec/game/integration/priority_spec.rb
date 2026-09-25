# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Priority (Game#pass_priority!)" do
  include_context "two player game"

  let(:game) { Magic::Game.new(enforce_priority: true) }

  describe "stack resolution" do
    it "resolves only the top item with resolve_top!" do
      go_to_main_phase!
      p1.add_mana(red: 2)
      p1.cast(card: Card("Lightning Bolt", owner: p1)) { |a| a.pay_mana(red: 1).targeting(p2) }
      p1.cast(card: Card("Lightning Bolt", owner: p1)) { |a| a.pay_mana(red: 1).targeting(p2) }

      expect(game.stack.count).to eq(2)
      game.stack.resolve_top!
      expect(game.stack.count).to eq(1)
      expect(p2.life).to eq(17)
    end
  end

  describe "passing" do
    before { go_to_main_phase! }

    it "gives the active player priority at the start of a step" do
      expect(game.priority_player).to eq(p1)
    end

    it "moves priority to the other player when the active player passes" do
      expect(game.pass_priority!).to eq(:passed)
      expect(game.priority_player).to eq(p2)
    end

    it "ends the step when both players pass in succession with an empty stack" do
      game.pass_priority!
      expect(game.pass_priority!).to eq(:step_ended)

      expect(current_turn.step).to eq("beginning_of_combat")
      expect(game.priority_player).to eq(p1)
    end

    it "walks through the whole turn one step at a time" do
      steps = []
      until current_turn.step == "cleanup"
        2.times { game.pass_priority! }
        steps << current_turn.step
      end

      expect(steps).to eq(%w[beginning_of_combat declare_attackers end_of_combat second_main end cleanup])
      expect(game.priority_player).to be_nil
    end

    it "resolves the top of the stack when both players pass, then the active player gets priority again" do
      p1.add_mana(red: 1)
      p1.cast(card: Card("Lightning Bolt", owner: p1)) { |a| a.pay_mana(red: 1).targeting(p2) }
      expect(game.priority_player).to eq(p1)

      game.pass_priority!
      expect(p2.life).to eq(20)
      expect(game.pass_priority!).to eq(:resolved)

      expect(p2.life).to eq(17)
      expect(game.stack).to be_empty
      expect(game.priority_player).to eq(p1)
      expect(current_turn.step).to eq("first_main")
    end
  end

  describe "responses" do
    before { go_to_main_phase! }

    it "lets the non-active player respond, and the response resolves first" do
      p1.add_mana(red: 1)
      p1.cast(card: Card("Lightning Bolt", owner: p1)) { |a| a.pay_mana(red: 1).targeting(p2) }
      game.pass_priority!

      p2.add_mana(blue: 2)
      p2.cast(card: Card("Counterspell", owner: p2)) do |a|
        a.pay_mana(blue: 2)
        a.targeting(game.stack.spells.first)
      end
      expect(game.priority_player).to eq(p2)

      # p2 passes, p1 passes: Counterspell resolves first.
      game.pass_priority!
      expect(game.pass_priority!).to eq(:resolved)
      expect(p2.life).to eq(20)
      expect(game.stack).to be_empty
    end

    it "restarts the pass count when a player casts a spell" do
      p1.add_mana(red: 1)
      p1.cast(card: Card("Lightning Bolt", owner: p1)) { |a| a.pay_mana(red: 1).targeting(p2) }
      game.pass_priority!

      p2.add_mana(red: 1)
      p2.cast(card: Card("Lightning Bolt", owner: p2)) { |a| a.pay_mana(red: 1).targeting(p1) }

      expect(game.priority_passes).to eq(0)
      expect(game.stack.count).to eq(2)
    end

    it "rejects an action from the player without priority" do
      p2.add_mana(red: 1)
      action = cast_action(card: Card("Lightning Bolt", owner: p2), player: p2)
      action.pay_mana(red: 1).targeting(p1)

      expect { game.take_action(action) }
        .to raise_error(Magic::IllegalAction, /does not have priority/)
    end

    it "does not require priority for mana abilities" do
      forest = ResolvePermanent("Forest", owner: p2)
      forest.untap!

      expect { p2.activate_ability(ability: forest.activated_abilities.first) }.not_to raise_error
    end
  end

  describe "triggered abilities" do
    before do
      ResolvePermanent("Wolverine Riders", owner: p1)
      game.check_state_based_actions!
      current_turn.untap!
      current_turn.upkeep!
    end

    it "waits on the stack so a player can respond to it" do
      expect(game.stack.abilities.count).to eq(1)
      expect(game.battlefield.creatures.count(&:token?)).to eq(0)
      expect(game.priority_player).to eq(p1)

      game.pass_priority!
      p2.add_mana(red: 1)
      p2.cast(card: Card("Lightning Bolt", owner: p2)) { |a| a.pay_mana(red: 1).targeting(p1) }
      game.pass_priority!
      expect(game.pass_priority!).to eq(:resolved)
      expect(p1.life).to eq(17)
      expect(game.battlefield.creatures.count(&:token?)).to eq(0)

      game.pass_priority!
      game.pass_priority!
      expect(game.battlefield.creatures.count(&:token?)).to eq(1)
    end
  end
end
