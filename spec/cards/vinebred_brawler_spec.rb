# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VinebredBrawler do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:brawler) { ResolvePermanent("Vinebred Brawler", owner: p1) }

  def attack!(*extra)
    skip_to_combat!
    current_turn.declare_attackers!
    [brawler, *extra].each { current_turn.declare_attacker(_1, target: p2) }
    game.settle!
    current_turn.attackers_declared!
  end

  it "is a 4/2 Elf Berserker" do
    expect([brawler.power, brawler.toughness]).to eq([4, 2])
  end

  it "must be blocked if able: leaving declare blockers without a block is illegal" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    attack!

    expect { current_turn.combat_damage! }.to raise_error(Magic::Game::CombatPhase::IllegalBlock, /must be blocked/)
  end

  it "is fine when it is blocked" do
    blocker = ResolvePermanent("Grizzly Bears", owner: p2)
    attack!
    current_turn.declare_blocker(blocker, attacker: brawler)

    expect { current_turn.combat_damage! }.not_to raise_error
  end

  it "is fine when nothing can block it" do
    attack!

    expect { current_turn.combat_damage! }.not_to raise_error
  end

  it "is fine when the only potential blocker is tapped" do
    ResolvePermanent("Grizzly Bears", owner: p2).tap!
    attack!

    expect { current_turn.combat_damage! }.not_to raise_error
  end

  it "gives another target Elf you control +2/+1 when it attacks" do
    elf = ResolvePermanent("Skyway Sniper", owner: p1)
    base = [elf.power, elf.toughness]
    attack!
    game.tick!

    expect([elf.power, elf.toughness]).to eq([base[0] + 2, base[1] + 1])
  end

  it "has no Elf to pump when it's alone, and doesn't pump non-Elves" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    attack!
    game.tick!

    expect(bears.power).to eq(2)
  end
end
