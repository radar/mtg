# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ClammyProwler do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:prowler) { ResolvePermanent("Clammy Prowler", owner: p1) }

  def attack!(*attackers)
    skip_to_combat!
    current_turn.declare_attackers!
    attackers.each { |a| current_turn.declare_attacker(a, target: p2) }
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 2/5 Enchantment Creature" do
    expect([prowler.power, prowler.toughness]).to eq([2, 5])
    expect(prowler).to be_enchantment
  end

  it "makes another attacking creature unblockable" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    blocker = ResolvePermanent("Grizzly Bears", owner: p2)
    attack!(prowler, bears)
    game.tick! # single legal target is chosen automatically

    expect { current_turn.declare_blocker(blocker, attacker: bears) }.to raise_error(Magic::Game::CombatPhase::IllegalBlock)
    expect { current_turn.declare_blocker(blocker, attacker: prowler) }.not_to raise_error
  end

  it "has no choice when attacking alone" do
    attack!(prowler)

    expect(game.choices).to be_empty
  end
end
