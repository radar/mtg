# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ArabellaAbandonedDoll do
  include_context "two player game"

  let!(:arabella) { ResolvePermanent("Arabella, Abandoned Doll", owner: p1) }

  def attack_with_arabella!
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: arabella, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a legendary 1/3 artifact creature" do
    expect([arabella.power, arabella.toughness]).to eq([1, 3])
    expect(arabella.type?("Artifact")).to be(true)
    expect(arabella.type?("Toy")).to be(true)
  end

  it "damages each opponent and gains life for each creature with power 2 or less" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Serra Angel", owner: p1)

    expect { attack_with_arabella! }.to change { p2.life }.by(-2).and change { p1.life }.by(2)
  end

  it "counts only creatures its controller controls" do
    ResolvePermanent("Grizzly Bears", owner: p2)

    expect { attack_with_arabella! }.to change { p2.life }.by(-1).and change { p1.life }.by(1)
  end
end
