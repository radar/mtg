# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KozileksUnsealing do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:unsealing) { ResolvePermanent("Kozilek's Unsealing", owner: p1) }

  def spawns(player = p1) = player.creatures.select { _1.name == "Eldrazi Spawn" }

  it "is a colorless enchantment" do
    expect(unsealing.colors).to be_empty
    expect(unsealing.enchantment?).to be(true)
  end

  it "creates two Eldrazi Spawn when you cast a creature spell with mana value 4" do
    card = Card("Beast Whisperer", owner: p1)
    p1.hand.add(card)
    p1.add_mana(green: 4)
    p1.cast(card: card) { |a| a.pay_mana(generic: { green: 2 }, green: 2) }
    game.settle!

    expect(spawns.count).to eq(2)
    expect(spawns.map { [_1.power, _1.toughness] }.uniq).to eq([[0, 1]])
  end

  it "creates two Eldrazi Spawn for mana value 6" do
    card = Card("Archway Angel", owner: p1)
    p1.hand.add(card)
    p1.add_mana(white: 1, green: 5)
    p1.cast(card: card) { |a| a.pay_mana(generic: { green: 5 }, white: 1) }
    game.settle!

    expect(spawns.count).to eq(2)
  end

  it "does nothing for a creature spell with mana value below 4" do
    card = Card("Elvish Mystic", owner: p1)
    p1.hand.add(card)
    p1.add_mana(green: 1)
    p1.cast(card: card) { |a| a.pay_mana(green: 1) }
    game.settle!

    expect(spawns).to be_empty
  end

  it "draws three cards, not Spawn, for mana value 7 or greater" do
    card = Card("Sire Of Seven Deaths", owner: p1)
    p1.hand.add(card)
    p1.add_mana(green: 7)
    hand_before = p1.hand.count - 1

    p1.cast(card: card) { |a| a.pay_mana(generic: { green: 7 }) }
    game.settle!

    expect(p1.hand.count).to eq(hand_before + 3)
    expect(spawns).to be_empty
  end

  it "does nothing when an opponent casts a creature spell" do
    go_to_main_phase_for!(p2)
    card = Card("Beast Whisperer", owner: p2)
    p2.hand.add(card)
    p2.add_mana(green: 4)
    p2.cast(card: card) { |a| a.pay_mana(generic: { green: 2 }, green: 2) }
    game.settle!

    expect(spawns).to be_empty
    expect(spawns(p2)).to be_empty
  end
end
