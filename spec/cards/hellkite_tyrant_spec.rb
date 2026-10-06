# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HellkiteTyrant do
  include_context "two player game"

  let!(:tyrant) { ResolvePermanent("Hellkite Tyrant", owner: p1) }

  def combat_damage_to(player)
    game.notify!(Magic::Events::DamageDealt.new(source: tyrant, target: player, damage: 6, combat: true))
    game.settle!
  end

  it "is a 6/5 flying, trampling Dragon" do
    expect([tyrant.power, tyrant.toughness]).to eq([6, 5])
    expect(tyrant).to be_flying
    expect(tyrant).to have_keyword(:trample)
  end

  it "gains control of all artifacts the damaged player controls" do
    sol = ResolvePermanent("Sol Ring", owner: p2)
    mender = ResolvePermanent("Circuit Mender", owner: p2)
    forest = ResolvePermanent("Forest", owner: p2)

    combat_damage_to(p2)

    expect(sol.controller).to eq(p1)
    expect(mender.controller).to eq(p1)
    expect(forest.controller).to eq(p2)
  end

  it "does not steal for damage to a creature, or noncombat damage" do
    sol = ResolvePermanent("Sol Ring", owner: p2)
    game.notify!(Magic::Events::DamageDealt.new(source: tyrant, target: p2, damage: 1, combat: false))
    game.settle!

    expect(sol.controller).to eq(p2)
  end

  it "wins the game at your upkeep with twenty or more artifacts" do
    20.times { ResolvePermanent("Sol Ring", owner: p1) }
    game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p1))
    game.settle!

    expect(p2).to be_lost
  end

  it "doesn't win with nineteen artifacts" do
    19.times { ResolvePermanent("Sol Ring", owner: p1) }
    game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p1))
    game.settle!

    expect(p2).not_to be_lost
  end

  it "doesn't win on the opponent's upkeep" do
    20.times { ResolvePermanent("Sol Ring", owner: p1) }
    game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p2))
    game.settle!

    expect(p2).not_to be_lost
  end
end
