# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TwinflameTyrant do
  include_context "two player game"

  let!(:tyrant) { ResolvePermanent("Twinflame Tyrant", owner: p1) }

  def shock(player, target)
    spell = Card("Shock", owner: player)
    player.hand.add(spell)
    player.add_mana(red: 1)
    player.cast(card: spell) { |a| a.pay_mana(red: 1).targeting(target) }
    game.settle!
  end

  def attack(attacker, target)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(attacker, target:)
    current_turn.attackers_declared!
    go_to_combat_damage!
    game.settle!
  end

  it "is a 3/5 Dragon with flying" do
    expect([tyrant.power, tyrant.toughness]).to eq([3, 5])
    expect(tyrant).to be_flying
  end

  it "doubles damage a source you control deals to an opponent" do
    shock(p1, p2)

    expect(p2.life).to eq(16)
  end

  it "doubles combat damage to an opponent" do
    attack(tyrant, p2)

    expect(p2.life).to eq(14)
  end

  it "doubles damage to a permanent an opponent controls" do
    wizard = ResolvePermanent("Erudite Wizard", owner: p2) # 2/3: a Shock's 2 wouldn't kill it, 4 does
    shock(p1, wizard)

    expect(p2.graveyard.cards.map(&:name)).to include("Erudite Wizard")
  end

  it "doesn't double damage to you" do
    shock(p1, p1)

    expect(p1.life).to eq(18)
  end

  it "doesn't double damage to your own permanents" do
    bears = ResolvePermanent("Erudite Wizard", owner: p1)
    shock(p1, bears)

    expect(bears.damage).to eq(2)
  end

  it "doesn't double damage an opponent's source deals" do
    shock(p2, p1)

    expect(p1.life).to eq(18)
  end

  it "stacks with a second Twinflame Tyrant" do
    ResolvePermanent("Twinflame Tyrant", owner: p1)
    shock(p1, p2)

    expect(p2.life).to eq(12)
  end
end
