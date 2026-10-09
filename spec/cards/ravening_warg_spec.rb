# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RaveningWarg do
  include_context "two player game"

  let!(:warg) { ResolvePermanent("Ravening Warg", owner: p1) }

  def attack_with(creature)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(creature, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 2/2 Wolf with deathtouch" do
    expect([warg.power, warg.toughness]).to eq([2, 2])
    expect(warg).to be_deathtouch
  end

  it "gains you 2 life when it attacks while you control a creature with power 4 or greater" do
    ResolvePermanent("Ordinary Bear", owner: p1)
    attack_with(warg)

    expect(p1.life).to eq(22)
  end

  it "doesn't gain life without a creature with power 4 or greater" do
    attack_with(warg)

    expect(p1.life).to eq(20)
  end
end
