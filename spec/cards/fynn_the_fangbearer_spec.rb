# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FynnTheFangbearer do
  include_context "two player game"

  let!(:fynn) { ResolvePermanent("Fynn, The Fangbearer", owner: p1) }

  def attack(*attackers, target: p2)
    skip_to_combat!
    current_turn.declare_attackers!
    attackers.each { current_turn.declare_attacker(_1, target:) }
    current_turn.attackers_declared!
    go_to_combat_damage!
    game.settle!
  end

  def poison(player) = player.counters.count

  it "is a legendary 1/3 Human Warrior with deathtouch" do
    expect([fynn.power, fynn.toughness]).to eq([1, 3])
    expect(fynn).to be_deathtouch
    expect(fynn).to be_legendary
  end

  it "gives the player two poison counters when Fynn itself deals combat damage to a player" do
    attack(fynn)

    expect(poison(p2)).to eq(2)
  end

  it "triggers for each deathtouch creature you control that connects" do
    nighthawk = ResolvePermanent("Vampire Nighthawk", owner: p1)
    attack(fynn, nighthawk)

    expect(poison(p2)).to eq(4)
  end

  it "ignores creatures without deathtouch" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    attack(bears)

    expect(poison(p2)).to eq(0)
  end

  it "gives no counters when the deathtouch creature is blocked" do
    blocker = ResolvePermanent("Grizzly Bears", owner: p2)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(fynn, target: p2)
    current_turn.attackers_declared!
    current_turn.declare_blocker(blocker, attacker: fynn)
    go_to_combat_damage!
    game.settle!

    expect(poison(p2)).to eq(0)
  end

  it "ignores an opponent's deathtouch creature dealing combat damage to you" do
    nighthawk = ResolvePermanent("Vampire Nighthawk", owner: p2)
    go_to_main_phase_for!(p2)
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(nighthawk, target: p1)
    current_turn.attackers_declared!
    go_to_combat_damage!
    game.settle!

    expect(p1.life).to eq(18)
    expect(poison(p1)).to eq(0)
  end
end
