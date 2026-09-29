# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BarbedBloodletter do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let(:card) { Card("Barbed Bloodletter", owner: p1) }

  def flash_in
    p1.hand.add(card)
    p1.add_mana(black: 2)
    p1.cast(card:) { _1.pay_mana(generic: { black: 1 }, black: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "has flash" do
    expect(card.flash?).to be(true)
  end

  it "attaches to target creature you control when it enters, which gains wither until end of turn" do
    flash_in
    game.tick!
    equipment = p1.permanents.find { _1.name == "Barbed Bloodletter" }

    expect(equipment.attached_to).to eq(bears)
    expect(bears).to be_wither
    expect([bears.power, bears.toughness]).to eq([3, 4])
  end

  it "wither: damage the equipped creature deals to a creature is dealt as -1/-1 counters" do
    flash_in
    game.tick!
    target = ResolvePermanent("Courser Of Kruphix", owner: p2)
    bears.trigger_effect(:deal_damage, source: bears, target:, damage: 2)

    expect(target.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(2)
    expect(target.damage).to eq(0)
  end

  it "wither also applies to combat damage, and lifelink still works" do
    flash_in
    game.tick!
    bears.grant_keyword(Magic::Cards::Keywords::LIFELINK)
    game.tick!
    blocker = ResolvePermanent("Courser Of Kruphix", owner: p2)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(bears, target: p2)
    current_turn.attackers_declared!
    current_turn.declare_blocker(blocker, attacker: bears)
    current_turn.combat_damage!
    game.settle!

    expect(blocker.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(3)
    expect(p1.life).to eq(23)
  end

  it "wither loses effect at end of turn, but the +1/+2 stays" do
    flash_in
    game.tick!
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect(bears).not_to be_wither
    expect([bears.power, bears.toughness]).to eq([3, 4])
  end

  it "can equip for {2}" do
    equipment = ResolvePermanent("Barbed Bloodletter", owner: p1)
    p1.add_mana(black: 2)
    p1.activate_ability(ability: equipment.activated_abilities.first) { _1.pay_mana(generic: { black: 2 }).targeting(bears) }
    game.stack.resolve!

    expect(equipment.attached_to).to eq(bears)
  end
end
