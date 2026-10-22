# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HexgoldSlith do
  include_context "two player game"

  let!(:slith) { ResolvePermanent("Hexgold Slith", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def attack(attacker)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: attacker, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  def counters(permanent) = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  it "is a 2/1 Slith" do
    expect([slith.power, slith.toughness]).to eq([2, 1])
    expect(slith.type?("Slith")).to be(true)
  end

  it "gives you two energy when it enters" do
    expect(p1.energy).to eq(2)
  end

  it "pays {E}{E} when it attacks to gain first strike" do
    attack(slith)
    game.resolve_choice!
    game.settle!

    expect(p1.energy).to eq(0)
    expect(slith.first_strike?).to be(true)
  end

  it "doesn't gain first strike when you decline" do
    attack(slith)
    game.skip_choice!
    game.settle!

    expect(p1.energy).to eq(2)
    expect(slith.first_strike?).to be(false)
  end

  it "offers nothing with fewer than two energy" do
    p1.pay_energy!(1)
    attack(slith)

    expect(game.choices).to be_empty
  end

  it "doesn't trigger when another creature attacks" do
    attack(bears)

    expect(game.choices).to be_empty
    expect(p1.energy).to eq(2)
  end

  it "gets a +1/+1 counter when it deals combat damage to a player" do
    attack(slith)
    game.skip_choice!
    go_to_combat_damage!
    game.settle!

    expect(p2.life).to eq(18)
    expect(counters(slith)).to eq(1)
    expect(slith.power).to eq(3)
  end

  it "gets no counter when it is blocked by a creature" do
    blocker = ResolvePermanent("Grizzly Bears", owner: p2)
    attack(slith)
    game.skip_choice!
    current_turn.declare_blocker(blocker, attacker: slith)
    go_to_combat_damage!
    game.settle!

    expect(counters(slith)).to eq(0)
  end
end
