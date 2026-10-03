# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GratuitousViolence do
  include_context "two player game"

  let!(:violence) { ResolvePermanent("Gratuitous Violence", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def attack(attacker, target)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(attacker, target:)
    current_turn.attackers_declared!
    go_to_combat_damage!
    game.settle!
  end

  it "is a {2}{R}{R}{R} enchantment" do
    card = Card("Gratuitous Violence", owner: p1)
    expect(card.cost.cost).to eq(generic: 2, red: 3)
    expect(card).to be_a(Magic::Cards::Enchantment)
  end

  it "doubles combat damage from a creature you control to a player" do
    attack(bears, p2)

    expect(p2.life).to eq(16)
  end

  it "doubles damage a creature you control deals to a permanent" do
    wizard = ResolvePermanent("Erudite Wizard", owner: p2) # 2/3
    bears.bite!(wizard) # 2 damage becomes 4: lethal
    game.settle!

    expect(p2.graveyard.cards.map(&:name)).to include("Erudite Wizard")
  end

  it "doubles damage to your own creatures too" do
    other = ResolvePermanent("Erudite Wizard", owner: p1)
    bears.bite!(other)

    expect(other.damage).to eq(4)
  end

  it "doesn't double damage from a spell" do
    spell = Card("Shock", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(red: 1)
    p1.cast(card: spell) { |a| a.pay_mana(red: 1).targeting(p2) }
    game.settle!

    expect(p2.life).to eq(18)
  end

  it "doesn't double damage from a creature an opponent controls" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    go_to_main_phase_for!(p2)
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(theirs, target: p1)
    current_turn.attackers_declared!
    go_to_combat_damage!
    game.settle!

    expect(p1.life).to eq(18)
  end
end
