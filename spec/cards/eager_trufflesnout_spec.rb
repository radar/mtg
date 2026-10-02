# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EagerTrufflesnout do
  include_context "two player game"

  let!(:boar) { ResolvePermanent("Eager Trufflesnout", owner: p1) }

  def attack!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(boar, target: p2)
    current_turn.attackers_declared!
    current_turn.combat_damage!
    game.settle!
  end

  it "is a 4/2 trampler" do
    expect([boar.power, boar.toughness]).to eq([4, 2])
    expect(boar).to be_trample
  end

  it "creates a Food token when it deals combat damage to a player" do
    attack!

    expect(p2.life).to eq(16)
    expect(p1.permanents.by_name("Food").count).to eq(1)
  end

  it "doesn't create Food when it's blocked" do
    blocker = ResolvePermanent("Grizzly Bears", owner: p2)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(boar, target: p2)
    current_turn.attackers_declared!
    current_turn.declare_blocker(blocker, attacker: boar)
    current_turn.combat_damage!
    game.settle!

    # 4 trample damage: 2 to the bears, 2 through to the player
    expect(p1.permanents.by_name("Food").count).to eq(1)
  end
end
