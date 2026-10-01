# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ChanneledDragonfire do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Channeled Dragonfire", owner: p1) }

  it "deals 2 damage to any target" do
    p1.add_mana(red: 1)
    p1.cast(card: card) { |a| a.pay_mana(red: 1).targeting(p2) }
    game.stack.resolve!

    expect(p2.life).to eq(18)
    expect(card.zone).to be_graveyard
  end

  it "can be harmonized from the graveyard for {5}{R}{R}, then is exiled" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.graveyard.add(card)
    p1.add_mana(red: 5)

    p1.cast(card: card, harmonize: true) do |a|
      a.harmonize_tap(bear)
      a.pay_mana(generic: { red: 3 }, red: 2).targeting(p2)
    end
    game.stack.resolve!

    expect(bear).to be_tapped
    expect(p2.life).to eq(18)
    expect(card.zone).to be_exile
  end

  it "can't be harmonized for less than its colored mana, and can't be cast from the graveyard without harmonize" do
    p1.graveyard.add(card)
    p1.add_mana(red: 1)

    expect { p1.cast(card: card) { |a| a.pay_mana(red: 1).targeting(p2) } }.to raise_error(Magic::IllegalAction)
  end
end
