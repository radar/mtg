# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FieryEmancipation do
  include_context "two player game"

  let!(:emancipation) { ResolvePermanent("Fiery Emancipation", owner: p1) }

  def shock(player, target)
    spell = Card("Shock", owner: player)
    player.hand.add(spell)
    player.add_mana(red: 1)
    player.cast(card: spell) { |a| a.pay_mana(red: 1).targeting(target) }
    game.settle!
  end

  it "triples damage a source you control deals to an opponent" do
    shock(p1, p2)

    expect(p2.life).to eq(14)
  end

  it "triples damage to a permanent" do
    bears = ResolvePermanent("Baneslayer Angel", owner: p2) # 5/5
    shock(p1, bears)

    expect(bears.damage).to eq(6)
  end

  it "triples damage to yourself" do
    shock(p1, p1)

    expect(p1.life).to eq(14)
  end

  it "doesn't triple damage an opponent's source deals" do
    shock(p2, p1)

    expect(p1.life).to eq(18)
  end

  it "triples combat damage" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(bears, target: p2)
    current_turn.attackers_declared!
    go_to_combat_damage!
    game.settle!

    expect(p2.life).to eq(14)
  end

  it "stacks with a second Fiery Emancipation" do
    ResolvePermanent("Fiery Emancipation", owner: p1)
    shock(p1, p2)

    expect(p2.life).to eq(2)
  end
end
