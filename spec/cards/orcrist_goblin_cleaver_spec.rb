# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OrcristGoblinCleaver do
  include_context "two player game"

  let!(:orcrist) { ResolvePermanent("Orcrist Goblin Cleaver", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def equip
    p1.add_mana(colorless: 3)
    p1.activate_ability(ability: orcrist.activated_abilities.first) do
      _1.targeting(bears)
      _1.pay_mana(generic: { colorless: 3 })
    end
    game.stack.resolve!
    game.tick!
  end

  def attack_with(creature)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(creature, target: p2)
    current_turn.attackers_declared!
    current_turn.combat_damage!
    game.settle!
  end

  def treasures = p1.permanents.select { _1.name == "Treasure" }

  it "is a legendary Equipment" do
    expect(orcrist).to be_legendary
    expect(orcrist.card).to be_a(Magic::Cards::Equipment)
  end

  it "needs {3} to equip" do
    p1.add_mana(colorless: 2)

    expect do
      p1.activate_ability(ability: orcrist.activated_abilities.first) do
        _1.targeting(bears)
        _1.pay_mana(generic: { colorless: 2 })
      end
    end.to raise_error(StandardError)
  end

  it "gives equipped creature +2/+2 and trample" do
    equip

    expect([bears.power, bears.toughness]).to eq([4, 4])
    expect(bears).to have_keyword(:trample)
  end

  it "creates a Treasure for each creature you control of the chosen type when equipped creature hits a player" do
    ResolvePermanent("Ordinary Bear", owner: p1)
    ResolvePermanent("Nori Teller Of Tales", owner: p1)
    equip
    attack_with(bears)
    game.resolve_choice!(creature_type: "Bear")
    game.settle!

    expect(p2.life).to eq(16)
    expect(treasures.count).to eq(2)
  end

  it "creates no Treasure for a type you don't control" do
    equip
    attack_with(bears)
    game.resolve_choice!(creature_type: "Elf")
    game.settle!

    expect(treasures).to be_empty
  end

  it "doesn't trigger when an unequipped creature deals combat damage" do
    other = ResolvePermanent("Ordinary Bear", owner: p1)
    equip
    attack_with(other)

    expect(game.choices).to be_empty
  end

  it "doesn't trigger when the equipped creature is blocked" do
    blocker = ResolvePermanent("Ordinary Bear", owner: p2)
    equip
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(bears, target: p2)
    current_turn.attackers_declared!
    current_turn.declare_blocker(blocker, attacker: bears)
    current_turn.combat_damage!
    game.settle!

    expect(game.choices).to be_empty
  end
end
