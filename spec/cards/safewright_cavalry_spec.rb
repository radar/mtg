# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SafewrightCavalry do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:cavalry) { ResolvePermanent("Safewright Cavalry", owner: p1) }

  def attack!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(cavalry, target: p2)
    current_turn.attackers_declared!
  end

  it "is a 4/4 Elf Warrior" do
    expect([cavalry.power, cavalry.toughness]).to eq([4, 4])
  end

  it "can be blocked by one creature" do
    blocker = ResolvePermanent("Grizzly Bears", owner: p2)
    attack!

    expect { current_turn.declare_blocker(blocker, attacker: cavalry) }.not_to raise_error
  end

  it "can't be blocked by more than one creature" do
    blockers = 2.times.map { ResolvePermanent("Grizzly Bears", owner: p2) }
    attack!
    current_turn.declare_blocker(blockers.first, attacker: cavalry)

    expect { current_turn.declare_blocker(blockers.last, attacker: cavalry) }
      .to raise_error(Magic::Game::CombatPhase::IllegalBlock, /more than 1 creature/)
  end

  it "has an ability: {5}: target Elf you control gets +2/+2 until end of turn" do
    elf = ResolvePermanent("Skyway Sniper", owner: p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(green: 5)
    p1.activate_ability(ability: cavalry.activated_abilities.first) { _1.pay_mana(generic: { green: 5 }).targeting(elf) }
    game.stack.resolve!
    game.tick!

    expect(elf.power).to eq(elf.card.class::POWER + 2)
    expect(bears.power).to eq(2)
    expect(cavalry.activated_abilities.first.target_choices).not_to include(bears)
  end
end
