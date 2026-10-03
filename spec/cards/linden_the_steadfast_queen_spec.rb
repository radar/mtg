# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LindenTheSteadfastQueen do
  include_context "two player game"

  let!(:linden) { ResolvePermanent("Linden, The Steadfast Queen", owner: p1) }

  def attack_with(*attackers, target: p2)
    skip_to_combat!
    current_turn.declare_attackers!
    attackers.each { current_turn.declare_attacker(_1, target:) }
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a legendary 3/3 Human Noble with vigilance" do
    expect([linden.power, linden.toughness]).to eq([3, 3])
    expect(linden).to be_vigilant
    expect(linden).to be_legendary
    expect(linden.type?("Noble")).to be(true)
  end

  it "gains 1 life when a white creature you control attacks (herself included)" do
    attack_with(linden)

    expect(p1.life).to eq(21)
  end

  it "gains 1 life for each white attacker" do
    lions = ResolvePermanent("Savannah Lions", owner: p1)
    attack_with(linden, lions)

    expect(p1.life).to eq(22)
  end

  it "does not gain life when a non-white creature attacks" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    attack_with(bears)

    expect(p1.life).to eq(20)
  end

  it "does not gain life when an opponent's white creature attacks" do
    lions = ResolvePermanent("Savannah Lions", owner: p2)
    go_to_main_phase_for!(p2)
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(lions, target: p1)
    current_turn.attackers_declared!
    game.settle!

    expect(p1.life).to eq(20)
  end
end
