# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EastMarkCavalier do
  include_context "two player game"

  let!(:cavalier) { ResolvePermanent("East-Mark Cavalier", owner: p1) }

  def attack_blocked(attacker, blocker)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(attacker, target: p2)
    current_turn.attackers_declared!
    current_turn.declare_blocker(blocker, attacker: attacker)
    go_to_combat_damage!
    game.settle!
  end

  it "is a 2/2 Human Knight with vigilance" do
    expect([cavalier.power, cavalier.toughness]).to eq([2, 2])
    expect(cavalier.has_keyword?(Magic::Cards::Keywords::VIGILANCE)).to eq(true)
  end

  it "destroys a Orc it deals damage to, even if the Orc would survive" do
    orc = ResolvePermanent("Warg Rider", owner: p2)
    attack_blocked(cavalier, orc)
    expect(p2.graveyard.cards.map(&:name)).to include("Warg Rider")
    expect(orc.zone).to be_nil
  end

  it "destroys a Goblin that blocks it" do
    goblin = ResolvePermanent("Goblin Arsonist", owner: p2)
    attack_blocked(cavalier, goblin)
    expect(p2.graveyard.cards.map(&:name)).to include("Goblin Arsonist")
  end

  it "destroys a Goblin or Orc it deals damage to when blocking" do
    current_turn.end!
    current_turn.cleanup!
    resolve_cleanup_discards!
    go_to_main_phase_for!(p2)
    orc = ResolvePermanent("Cirith Ungol Patrol", owner: p2)
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(orc, target: p1)
    current_turn.attackers_declared!
    current_turn.declare_blocker(cavalier, attacker: orc)
    go_to_combat_damage!
    game.settle!
    expect(p2.graveyard.cards.map(&:name)).to include("Cirith Ungol Patrol")
  end

  it "does not destroy a creature that is not a Goblin or Orc" do
    bear = ResolvePermanent("Gigantic Big Bear", owner: p2)
    attack_blocked(cavalier, bear)
    expect(bear.zone).to be_battlefield
    expect(p2.graveyard.cards.map(&:name)).not_to include("Gigantic Big Bear")
  end

  it "does nothing when it damages a player" do
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(cavalier, target: p2)
    current_turn.attackers_declared!
    go_to_combat_damage!
    game.settle!
    expect(p2.life).to eq(18)
    expect(game.choices).to be_empty
  end

  it "does not destroy a Goblin or Orc dealt damage by another source" do
    orc = ResolvePermanent("Warg Rider", owner: p2)
    ally = ResolvePermanent("Grizzly Bears", owner: p1)
    attack_blocked(ally, orc)
    expect(orc.zone).to be_battlefield
  end
end
