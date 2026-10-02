# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VampireNighthawk do
  include_context "two player game"

  let!(:nighthawk) { ResolvePermanent("Vampire Nighthawk", owner: p1) }

  it "is a 2/3 flying, deathtouch, lifelink Vampire Shaman" do
    expect([nighthawk.power, nighthawk.toughness]).to eq([2, 3])
    expect(nighthawk).to be_flying
    expect(nighthawk).to be_deathtouch
    expect(nighthawk).to be_lifelink
  end

  it "gains you life for the damage it deals to a player" do
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(nighthawk, target: p2)
    current_turn.attackers_declared!
    current_turn.combat_damage!
    game.settle!

    expect(p2.life).to eq(18)
    expect(p1.life).to eq(22)
  end

  it "destroys any creature it deals damage to" do
    blocker = ResolvePermanent("Magnigoth Sentry", owner: p2) # a 4/4 with reach
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(nighthawk, target: p2)
    current_turn.attackers_declared!
    current_turn.declare_blocker(blocker, attacker: nighthawk)
    current_turn.combat_damage!
    game.settle!

    expect(blocker.card.zone).to be_graveyard
  end
end
