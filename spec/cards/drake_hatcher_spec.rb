# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DrakeHatcher do
  include_context "two player game"

  let!(:hatcher) { ResolvePermanent("Drake Hatcher", owner: p1) }

  def incubation = hatcher.counters.of_type(Magic::Counters["incubation"]).count

  def attack
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(hatcher, target: p2)
    current_turn.attackers_declared!
    go_to_combat_damage!
    game.settle!
  end

  def drakes = p1.creatures.select { _1.type?("Drake") }

  it "is a 1/3 Human Wizard with vigilance and prowess" do
    expect([hatcher.power, hatcher.toughness]).to eq([1, 3])
    expect(hatcher).to be_vigilant
    expect(hatcher.card.keywords).to include(Magic::Cards::Keywords::PROWESS)
  end

  it "puts that many incubation counters on itself when it deals combat damage to a player" do
    attack

    expect(p2.life).to eq(19)
    expect(incubation).to eq(1)
  end

  it "puts as many counters as the damage dealt (prowess makes it 2)" do
    spell = Card("Shock", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(red: 1)
    skip_to_combat!
    p1.cast(card: spell) { |a| a.pay_mana(red: 1).targeting(p2) }
    game.settle!
    current_turn.declare_attackers!
    current_turn.declare_attacker(hatcher, target: p2)
    current_turn.attackers_declared!
    go_to_combat_damage!
    game.settle!

    expect(incubation).to eq(2)
  end

  it "gets no counters when blocked" do
    blocker = ResolvePermanent("Grizzly Bears", owner: p2)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(hatcher, target: p2)
    current_turn.attackers_declared!
    current_turn.declare_blocker(blocker, attacker: hatcher)
    go_to_combat_damage!
    game.settle!

    expect(incubation).to eq(0)
  end

  it "removes three incubation counters to create a 2/2 blue Drake with flying" do
    hatcher.trigger_effect(:add_counter, counter_type: "incubation", target: hatcher, amount: 3)
    p1.activate_ability(ability: hatcher.activated_abilities.first)
    game.stack.resolve!

    expect(incubation).to eq(0)
    expect(drakes.count).to eq(1)
    drake = drakes.first
    expect([drake.power, drake.toughness]).to eq([2, 2])
    expect(drake).to be_flying
    expect(drake.colors).to eq([:blue])
  end

  it "can't be activated with fewer than three counters" do
    hatcher.trigger_effect(:add_counter, counter_type: "incubation", target: hatcher, amount: 2)

    expect { p1.activate_ability(ability: hatcher.activated_abilities.first) }.to raise_error(StandardError)
    expect(drakes).to be_empty
  end
end
