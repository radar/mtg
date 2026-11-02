# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MoriaMarauder do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:marauder) { ResolvePermanent("Moria Marauder", owner: p1) }
  let(:forests) { Array.new(4) { Card("Forest", owner: p1) } }

  before { forests.each { p1.library.add(_1) } }

  def attack_with(*creatures, blocker: nil, player: p1, target: p2)
    skip_to_combat! if player == p1
    current_turn.declare_attackers!
    creatures.each { current_turn.declare_attacker(_1, target: target) }
    current_turn.attackers_declared!
    current_turn.declare_blocker(blocker, attacker: creatures.first) if blocker
    go_to_combat_damage!
    game.settle!
  end

  def exiled = forests.select { _1.zone == game.exile }

  it "is a 1/1 Goblin Warrior with double strike" do
    expect([marauder.power, marauder.toughness]).to eq([1, 1])
    expect(marauder.type?("Goblin")).to eq(true)
    expect(marauder.has_keyword?(Magic::Cards::Keywords::DOUBLE_STRIKE)).to eq(true)
  end

  it "exiles a card for each of its own two strikes that hit a player" do
    attack_with(marauder)
    expect(p2.life).to eq(18)
    expect(exiled.size).to eq(2)
  end

  it "triggers for another Goblin you control" do
    goblin = ResolvePermanent("Goblin Arsonist", owner: p1)
    attack_with(goblin)
    expect(exiled.size).to eq(1)
  end

  it "triggers for an Orc you control" do
    orc = ResolvePermanent("Warg Rider", owner: p1)
    attack_with(orc)
    expect(exiled.size).to eq(1)
  end

  it "triggers once per creature, not once per group" do
    goblin = ResolvePermanent("Goblin Arsonist", owner: p1)
    orc = ResolvePermanent("Warg Rider", owner: p1)
    attack_with(goblin, orc)
    expect(exiled.size).to eq(2)
  end

  it "lets you play the exiled card this turn" do
    goblin = ResolvePermanent("Goblin Arsonist", owner: p1)
    attack_with(goblin)
    land = exiled.first
    current_turn.end_of_combat!
    current_turn.second_main!
    p1.play_land(land: land)
    game.settle!
    expect(p1.lands.map(&:card)).to include(land)
  end

  it "does not let you play the exiled card on a later turn" do
    goblin = ResolvePermanent("Goblin Arsonist", owner: p1)
    attack_with(goblin)
    land = exiled.first
    current_turn.end!
    current_turn.cleanup!
    game.tick!
    expect { p1.play_land(land: land) }.to raise_error(Magic::IllegalAction)
  end

  it "does nothing for a creature that is not a Goblin or Orc" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    attack_with(bear)
    expect(p2.life).to eq(18)
    expect(exiled).to be_empty
  end

  it "does nothing when the Goblin is blocked" do
    goblin = ResolvePermanent("Goblin Arsonist", owner: p1)
    blocker = ResolvePermanent("Serra Angel", owner: p2)
    attack_with(goblin, blocker: blocker)
    expect(exiled).to be_empty
  end

  it "does nothing when an opponent's Goblin deals combat damage to you" do
    current_turn.end!
    current_turn.cleanup!
    resolve_cleanup_discards!
    go_to_main_phase_for!(p2)
    theirs = ResolvePermanent("Goblin Arsonist", owner: p2)
    current_turn.beginning_of_combat!
    attack_with(theirs, player: p2, target: p1)
    expect(p1.life).to eq(19)
    expect(exiled).to be_empty
  end

  it "does nothing with an empty library" do
    p1.library.cards.clear
    goblin = ResolvePermanent("Goblin Arsonist", owner: p1)
    attack_with(goblin)
    expect(game.exile.cards).to be_empty
    expect(game.choices).to be_empty
  end
end
