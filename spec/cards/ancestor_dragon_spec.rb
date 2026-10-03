# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AncestorDragon do
  include_context "two player game"

  let!(:dragon) { ResolvePermanent("Ancestor Dragon", owner: p1) }

  def attack_with(*attackers, target: p2)
    skip_to_combat!
    current_turn.declare_attackers!
    attackers.each { current_turn.declare_attacker(_1, target:) }
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 5/6 Dragon with flying" do
    expect([dragon.power, dragon.toughness]).to eq([5, 6])
    expect(dragon).to be_flying
    expect(dragon.type?("Dragon")).to be(true)
  end

  it "gains 1 life for each attacking creature, once" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    attack_with(dragon, bears)

    expect(p1.life).to eq(22)
  end

  it "triggers when a single other creature attacks and the Dragon stays home" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    attack_with(bears)

    expect(p1.life).to eq(21)
  end

  it "does nothing when nobody attacks" do
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.attackers_declared!
    game.settle!

    expect(p1.life).to eq(20)
  end

  it "does not trigger on an opponent's attack" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    go_to_main_phase_for!(p2)
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(bears, target: p1)
    current_turn.attackers_declared!
    game.settle!

    expect(p1.life).to eq(20)
  end
end
