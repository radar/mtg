# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThrivingSkyclaw do
  include_context "two player game"

  let!(:claw) { ResolvePermanent("Thriving Skyclaw", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def attack(*attackers)
    skip_to_combat!
    current_turn.declare_attackers!
    attackers.each { |attacker| p1.declare_attacker(attacker: attacker, target: p2) }
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 3/2 flying Cat Dragon" do
    expect([claw.power, claw.toughness]).to eq([3, 2])
    expect(claw.has_keyword?(:flying)).to be(true)
    expect(claw.type?("Cat")).to be(true)
    expect(claw.type?("Dragon")).to be(true)
  end

  it "gives you three energy when it enters" do
    expect(p1.energy).to eq(3)
  end

  it "pays {E}{E}{E} when it attacks to put a +1/+1 counter on it" do
    attack(claw)
    game.resolve_choice!
    game.settle!

    expect(p1.energy).to eq(0)
    expect([claw.power, claw.toughness]).to eq([4, 3])
  end

  it "does nothing and keeps the energy when you decline" do
    attack(claw)
    game.skip_choice!
    game.settle!

    expect(p1.energy).to eq(3)
    expect(claw.power).to eq(3)
  end

  it "offers nothing with fewer than three energy" do
    p1.pay_energy!(1)
    attack(claw)

    expect(game.choices).to be_empty
    expect(claw.power).to eq(3)
  end

  it "doesn't trigger when another creature attacks" do
    attack(bears)

    expect(game.choices).to be_empty
    expect(p1.energy).to eq(3)
  end
end
