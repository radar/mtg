# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThoughtweftImbuer do
  include_context "two player game"

  let!(:imbuer) { ResolvePermanent("Thoughtweft Imbuer", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def attack_with(*attackers)
    skip_to_combat!
    current_turn.declare_attackers!
    attackers.each { p1.declare_attacker(attacker: _1, target: p2) }
    current_turn.attackers_declared!
    game.tick!
  end

  it "is a 0/5 Kithkin Advisor" do
    expect([imbuer.power, imbuer.toughness]).to eq([0, 5])
    expect(imbuer.type?("Kithkin")).to eq(true)
  end

  it "gives a creature attacking alone +X/+X, X the Kithkin you control" do
    ResolvePermanent("Timid Shieldbearer", owner: p1)
    attack_with(bears)
    # Imbuer and Timid Shieldbearer are Kithkin: X = 2
    expect([bears.power, bears.toughness]).to eq([4, 4])
  end

  it "counts itself when it attacks alone" do
    attack_with(imbuer)
    expect([imbuer.power, imbuer.toughness]).to eq([1, 6])
  end

  it "does nothing when more than one creature attacks" do
    attack_with(bears, imbuer)
    expect([bears.power, bears.toughness]).to eq([2, 2])
  end

  it "ignores Kithkin the opponent controls" do
    ResolvePermanent("Timid Shieldbearer", owner: p2)
    attack_with(bears)
    expect(bears.power).to eq(3)
  end
end
