# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DesertWereWorm do
  include_context "two player game"

  let!(:worm) { ResolvePermanent("Desert Were-Worm", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def mountains(count) = count.times { ResolvePermanent("Mountain", owner: p1) }

  def attack
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: worm, target: p2)
    p1.declare_attacker(attacker: bears, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.stack.resolve!
    game.tick!
  end

  it "is a 0/5 Dragon Wurm" do
    expect([worm.power, worm.toughness]).to eq([0, 5])
    expect(worm.type?("Wurm")).to eq(true)
  end

  it "gets +2/+0 for each Mountain you control" do
    mountains(3)
    game.tick!
    expect(worm.power).to eq(6)
    ResolvePermanent("Forest", owner: p1)
    game.tick!
    expect(worm.power).to eq(6)
  end

  context "when attacking with total power 12 or greater" do
    before do
      mountains(5)
      game.tick!
    end

    it "untaps all attacking creatures and queues an additional combat" do
      attack
      expect(worm).not_to be_tapped
      expect(bears).not_to be_tapped
      expect(current_turn.additional_combat_pending?).to be true
    end

    it "triggers only the first time each turn" do
      attack
      go_to_combat_damage!
      current_turn.end_of_combat!
      current_turn.second_main!
      expect(current_turn).to be_beginning_of_combat

      current_turn.declare_attackers!
      p1.declare_attacker(attacker: worm, target: p2)
      p1.declare_attacker(attacker: bears, target: p2)
      current_turn.attackers_declared!
      game.settle!
      game.stack.resolve!

      expect(worm).to be_tapped
      expect(current_turn.additional_combat_pending?).to be false
    end
  end

  it "does not trigger with total power under 12" do
    mountains(4)
    game.tick!
    attack
    expect(worm).to be_tapped
    expect(current_turn.additional_combat_pending?).to be false
  end
end
