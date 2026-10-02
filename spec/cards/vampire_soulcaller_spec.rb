# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VampireSoulcaller do
  include_context "two player game"

  let(:dead_bears) { Card("Grizzly Bears", owner: p1) }

  it "is a 3/2 flying Vampire Warlock" do
    soulcaller = ResolvePermanent("Vampire Soulcaller", owner: p1)

    expect([soulcaller.power, soulcaller.toughness]).to eq([3, 2])
    expect(soulcaller).to be_flying
  end

  it "returns target creature card from your graveyard to your hand when it enters" do
    p1.graveyard.add(dead_bears)
    p1.graveyard.add(Card("Bear Cub", owner: p1))
    ResolvePermanent("Vampire Soulcaller", owner: p1)
    game.resolve_choice!(target: dead_bears)

    expect(dead_bears.zone).to be_hand
  end

  it "can't return a noncreature card" do
    bolt = Card("Boltwave", owner: p1)
    p1.graveyard.add(bolt)
    p1.graveyard.add(dead_bears)
    p1.graveyard.add(Card("Bear Cub", owner: p1))
    ResolvePermanent("Vampire Soulcaller", owner: p1)

    expect(game.choices.last.choices).not_to include(bolt)
  end

  it "can't block" do
    soulcaller = ResolvePermanent("Vampire Soulcaller", owner: p1)
    attacker = ResolvePermanent("Healer's Hawk", owner: p2)
    go_to_main_phase_for!(p2)
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(attacker, target: p1)
    current_turn.attackers_declared!

    expect { current_turn.declare_blocker(soulcaller, attacker:) }.to raise_error(Magic::Game::CombatPhase::IllegalBlock)
  end
end
