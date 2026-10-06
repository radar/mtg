# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ChandrasPyreling do
  include_context "two player game"

  let!(:pyreling) { ResolvePermanent("Chandra's Pyreling", owner: p1) }

  def shock(player, target)
    spell = Card("Shock", owner: player)
    player.hand.add(spell)
    player.add_mana(red: 1)
    player.cast(card: spell) { |a| a.pay_mana(red: 1).targeting(target) }
    game.settle!
  end

  it "is a 1/3 Elemental Lizard" do
    expect([pyreling.power, pyreling.toughness]).to eq([1, 3])
  end

  it "gets +1/+0 and double strike when a source you control deals noncombat damage to an opponent" do
    shock(p1, p2)
    game.tick!

    expect(pyreling.power).to eq(2)
    expect(pyreling.has_keyword?(Magic::Cards::Keywords::DOUBLE_STRIKE)).to eq(true)
  end

  it "ignores noncombat damage to a creature" do
    shock(p1, ResolvePermanent("Grizzly Bears", owner: p2))
    game.tick!

    expect(pyreling.power).to eq(1)
  end

  it "ignores damage an opponent's source deals" do
    shock(p2, p1)
    game.tick!

    expect(pyreling.power).to eq(1)
  end

  it "ignores combat damage" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(bears, target: p2)
    current_turn.attackers_declared!
    go_to_combat_damage!
    game.settle!

    expect(pyreling.power).to eq(1)
  end
end
