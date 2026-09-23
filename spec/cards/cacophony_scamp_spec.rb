# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CacophonyScamp do
  include_context "two player game"

  subject!(:scamp) { ResolvePermanent("Cacophony Scamp", owner: p1) }

  it "is a 1/1 Phyrexian Goblin Warrior" do
    expect(scamp.power).to eq(1)
    expect(scamp.toughness).to eq(1)
  end

  context "when it deals combat damage to a player" do
    before do
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(scamp, target: p2)
      go_to_combat_damage!
    end

    it "may sacrifice it, and if you do, proliferate" do
      counter_bears = ResolvePermanent("Grizzly Bears", owner: p1)
      counter_bears.add_counter("+1/+1")

      game.resolve_choice!
      game.resolve_choice!(chosen: [counter_bears])

      expect(scamp.zone).to be_nil
      expect(counter_bears.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(2)
    end

    it "does nothing if you decline to sacrifice it" do
      game.skip_choice!

      expect(scamp.zone).not_to be_nil
    end
  end

  context "when another creature you control deals combat damage to a player" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    before do
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(bears, target: p2)
      go_to_combat_damage!
    end

    it "does not offer to sacrifice Cacophony Scamp" do
      expect(game.choices).to be_empty
    end
  end

  context "when it deals combat damage to a blocking creature, not a player" do
    let!(:blocker) { ResolvePermanent("Warded Battlements", owner: p2) }

    before do
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(scamp, target: p2)
      current_turn.attackers_finalized!
      current_turn.declare_blocker(blocker, attacker: scamp)
      go_to_combat_damage!
    end

    it "does not offer to sacrifice it" do
      expect(game.choices).to be_empty
    end
  end

  context "when it dies" do
    it "deals damage equal to its power to any target" do
      bear = ResolvePermanent("Grizzly Bears", owner: p2)
      scamp.destroy!
      game.settle!

      game.resolve_choice!(target: bear)

      expect(bear.damage).to eq(1)
    end

    it "deals damage equal to its power to a player" do
      scamp.destroy!
      game.settle!

      game.resolve_choice!(target: p2)

      expect(p2.life).to eq(19)
    end
  end
end
