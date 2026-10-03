# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StromkirkNoble do
  include_context "two player game"

  let!(:noble) { ResolvePermanent("Stromkirk Noble", owner: p1) }

  def attack
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(noble, target: p2)
    current_turn.attackers_declared!
  end

  it "is a 1/1 Vampire" do
    expect([noble.power, noble.toughness]).to eq([1, 1])
    expect(noble.type?("Vampire")).to be(true)
  end

  it "can't be blocked by Humans" do
    human = ResolvePermanent("Erudite Wizard", owner: p2)
    attack

    expect { current_turn.declare_blocker(human, attacker: noble) }.to raise_error(Magic::Game::CombatPhase::IllegalBlock)
  end

  it "can be blocked by a non-Human" do
    bear = ResolvePermanent("Grizzly Bears", owner: p2)
    attack

    expect { current_turn.declare_blocker(bear, attacker: noble) }.not_to raise_error
  end

  it "gets a +1/+1 counter when it deals combat damage to a player" do
    attack
    go_to_combat_damage!
    game.settle!

    expect(p2.life).to eq(19)
    expect([noble.power, noble.toughness]).to eq([2, 2])
  end

  it "gets no counter when it's blocked" do
    bear = ResolvePermanent("Grizzly Bears", owner: p2)
    attack
    current_turn.declare_blocker(bear, attacker: noble)
    go_to_combat_damage!
    game.settle!

    expect(p2.life).to eq(20)
  end
end
