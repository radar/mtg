# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KardurDoomscourge do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:kardur) { ResolvePermanent("Kardur Doomscourge", owner: p1, summoning_sick: true) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  it "forces opponents' creatures to attack until its controller's next turn" do
    expect(bears).to be_must_attack
  end

  it "doesn't force its controller's creatures to attack" do
    mine = ResolvePermanent("Grizzly Bears", owner: p1)

    expect(mine).not_to be_must_attack
  end

  it "stops forcing attacks once its controller begins another turn" do
    current_turn.end!
    current_turn.cleanup!
    resolve_cleanup_discards!
    go_to_main_phase_for!(p2)
    expect(bears).to be_must_attack

    current_turn.end!
    current_turn.cleanup!
    go_to_main_phase_for!(p1)
    expect(bears).not_to be_must_attack
  end

  describe "when an attacking creature dies" do
    def attack_with(creature, from:)
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(creature, target: from)
      current_turn.attackers_declared!
      game.settle!
    end

    it "drains each opponent for 1" do
      mine = ResolvePermanent("Grizzly Bears", owner: p1)
      attack_with(mine, from: p2)
      mine.destroy!
      game.settle!

      expect(p2.life).to eq(19)
      expect(p1.life).to eq(21)
    end

    it "doesn't trigger for a creature that isn't attacking" do
      bears.destroy!
      game.settle!

      expect(p2.life).to eq(20)
    end
  end
end
