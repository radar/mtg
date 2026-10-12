# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UnstoppableSlasher do
  include_context "two player game"

  let!(:slasher) { ResolvePermanent("Unstoppable Slasher", owner: p1) }

  def slashers = game.battlefield.creatures.by_name("Unstoppable Slasher")

  it "is a 2/3 deathtouch Zombie Assassin" do
    expect([slasher.power, slasher.toughness]).to eq([2, 3])
    expect(slasher).to be_deathtouch
    expect(slasher).to be_type("Zombie")
  end

  it "makes a player lose half their life, rounded up, when it deals combat damage to them" do
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(slasher, target: p2)
    go_to_combat_damage!
    game.settle!

    # 20 - 2 combat damage = 18, then lose half of 18
    expect(p2.life).to eq(9)
  end

  it "rounds the life loss up" do
    p2.lose_life(7)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(slasher, target: p2)
    go_to_combat_damage!
    game.settle!

    # 13 - 2 = 11, lose half rounded up = 6
    expect(p2.life).to eq(5)
  end

  context "when it dies with no counters on it" do
    before do
      slasher.destroy!
      game.settle!
    end

    it "returns tapped with two stun counters" do
      expect(slashers.count).to eq(1)
      returned = slashers.first
      expect(returned).to be_tapped
      expect(returned.counters.count).to eq(2)
      expect(returned.counters.of_type(Magic::Counters::Stun).count).to eq(2)
      expect(returned.controller).to eq(p1)
    end

    it "stays dead the second time, since it now has counters" do
      slashers.first.destroy!
      game.settle!

      expect(slashers).to be_empty
    end
  end

  it "stays dead if it had a counter on it" do
    slasher.add_counter("+1/+1")
    game.settle!
    slasher.destroy!
    game.settle!

    expect(slashers).to be_empty
    expect(slasher.card.zone).to be_graveyard
  end
end
