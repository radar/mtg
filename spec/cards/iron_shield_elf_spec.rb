# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::IronShieldElf do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:elf) { ResolvePermanent("Iron-Shield Elf", owner: p1) }

  it "is a 3/1 Elf Warrior" do
    expect([elf.power, elf.toughness]).to eq([3, 1])
  end

  it "discards a card to gain indestructible until end of turn and tap itself" do
    card = p1.hand.cards.first
    p1.activate_ability(ability: elf.activated_abilities.first) { _1.pay_discard(card) }
    game.stack.resolve!
    game.tick!

    expect(card.zone).to be_graveyard
    expect(elf).to be_indestructible
    expect(elf).to be_tapped
  end

  it "survives lethal damage while indestructible" do
    p1.activate_ability(ability: elf.activated_abilities.first) { _1.pay_discard(p1.hand.cards.first) }
    game.stack.resolve!
    game.tick!
    elf.trigger_effect(:deal_damage, source: p2, target: elf, damage: 5)
    game.settle!

    expect(elf.zone).to be_battlefield
  end

  it "wears off at end of turn" do
    p1.activate_ability(ability: elf.activated_abilities.first) { _1.pay_discard(p1.hand.cards.first) }
    game.stack.resolve!
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect(elf).not_to be_indestructible
  end

  it "can be activated while tapped (there's no {T} in the cost)" do
    elf.tap!
    p1.activate_ability(ability: elf.activated_abilities.first) { _1.pay_discard(p1.hand.cards.first) }
    game.stack.resolve!
    game.tick!

    expect(elf).to be_indestructible
  end
end
