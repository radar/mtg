# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TidingsOfWar do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Tidings Of War", owner: p1) }

  def army = p1.creatures.find { _1.type?("Army") }

  it "amasses Goblins 1" do
    p1.hand.add(card)
    p1.add_mana(red: 1)
    p1.cast(card:) { _1.pay_mana(red: 1) }
    game.stack.resolve!
    game.tick!

    expect(army.type?("Goblin")).to eq(true)
    expect([army.power, army.toughness]).to eq([1, 1])
  end

  it "puts counters on the Army you already control" do
    p1.hand.add(card)
    p1.add_mana(red: 1)
    p1.cast(card:) { _1.pay_mana(red: 1) }
    game.stack.resolve!
    second = Card("Tidings Of War", owner: p1)
    p1.hand.add(second)
    p1.add_mana(red: 1)
    p1.cast(card: second) { _1.pay_mana(red: 1) }
    game.stack.resolve!
    game.tick!

    expect(p1.creatures.count { _1.type?("Army") }).to eq(1)
    expect(army.power).to eq(2)
  end

  it "amasses Goblins 3 instead when cast with flashback from the graveyard" do
    p1.graveyard.add(card)
    p1.add_mana(red: 4)
    p1.cast(card:, flashback: true) { _1.pay_mana(generic: { red: 3 }, red: 1) }
    game.stack.resolve!
    game.tick!

    expect(army.power).to eq(3)
    expect(card.zone).to be_exile
  end
end
