# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HoodedBlightfang do
  include_context "two player game"

  let!(:blightfang) { ResolvePermanent("Hooded Blightfang", owner: p1) }

  it "is a 1/4 Snake with deathtouch" do
    expect([blightfang.power, blightfang.toughness]).to eq([1, 4])
    expect(blightfang).to be_deathtouch
  end

  it "drains 1 whenever a creature you control with deathtouch attacks" do
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: blightfang, target: p2)
    current_turn.attackers_declared!
    game.settle!

    expect(p2.life).to eq(19)
    expect(p1.life).to eq(21)
  end

  it "doesn't trigger for an attacker without deathtouch" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: bears, target: p2)
    current_turn.attackers_declared!
    game.settle!

    expect(p2.life).to eq(20)
  end

  it "destroys a planeswalker dealt damage by a creature you control with deathtouch" do
    walker = ResolvePermanent("Ob Nixilis Reignited", owner: p2)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: blightfang, target: walker)
    current_turn.attackers_declared!
    go_to_combat_damage!
    game.settle!

    expect(walker.zone).not_to be_a(Magic::Zones::Battlefield)
  end

  it "doesn't destroy a planeswalker damaged by a creature without deathtouch" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    walker = ResolvePermanent("Ob Nixilis Reignited", owner: p2)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: bears, target: walker)
    current_turn.attackers_declared!
    go_to_combat_damage!
    game.settle!

    expect(walker.zone).to be_a(Magic::Zones::Battlefield)
  end
end
