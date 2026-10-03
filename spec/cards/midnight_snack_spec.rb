# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MidnightSnack do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:snack) { ResolvePermanent("Midnight Snack", owner: p1) }

  def foods(player = p1) = player.permanents.by_name("Food").to_a

  def attack!
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(bears, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  def end_turn!
    current_turn.end!
    game.settle!
  end

  describe "raid end step trigger" do
    it "creates a Food token at your end step if you attacked this turn" do
      attack!
      end_turn!

      expect(foods.size).to eq(1)
    end

    it "creates nothing if you didn't attack" do
      end_turn!

      expect(foods).to be_empty
    end

    it "doesn't count an opponent attacking" do
      game.next_turn
      go_to_main_phase!
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(bears, target: p1)
      current_turn.attackers_declared!
      end_turn!

      expect(foods).to be_empty
    end
  end

  describe "{2}{B}, sacrifice: target opponent loses X life" do
    def activate
      p1.add_mana(black: 3)
      p1.activate_ability(ability: snack.activated_abilities.first) { _1.pay_mana(generic: { black: 2 }, black: 1).targeting(p2) }
      game.stack.resolve!
      game.settle!
    end

    it "makes the opponent lose life equal to the life you gained this turn" do
      p1.gain_life(3)
      p1.gain_life(2)
      activate

      expect(p2.life).to eq(15)
      expect(snack.zone).not_to be_a(Magic::Zones::Battlefield)
    end

    it "does nothing harmful with no life gained, but still sacrifices" do
      activate

      expect(p2.life).to eq(20)
      expect(p1.permanents.by_name("Midnight Snack")).to be_empty
    end

    it "ignores life the opponent gained" do
      p2.gain_life(5)
      p1.gain_life(1)
      activate

      expect(p2.life).to eq(24)
    end
  end
end
