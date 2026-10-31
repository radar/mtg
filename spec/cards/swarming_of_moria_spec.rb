# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SwarmingOfMoria do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:spell) { Card("Swarming Of Moria", owner: p1) }

  def army = p1.creatures.by_type("Army").first
  def treasures = p1.permanents.select { _1.type?("Treasure") }

  def cast_spell
    p1.hand.add(spell)
    p1.add_mana(red: 3)
    p1.cast(card: spell) { |a| a.pay_mana(generic: { red: 2 }, red: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "is a {2}{R} sorcery" do
    expect(spell.cost.cost).to eq(generic: 2, red: 1)
    expect(spell).to be_a(Magic::Cards::Sorcery)
  end

  it "creates a Treasure token for its controller only" do
    cast_spell

    expect(treasures.count).to eq(1)
    expect(p2.permanents.select { _1.type?("Treasure") }).to be_empty
  end

  it "amasses Orcs 2, creating a black Orc Army with two +1/+1 counters" do
    cast_spell

    expect(army.type?("Orc")).to be(true)
    expect(army.colors).to eq([:black])
    expect([army.power, army.toughness]).to eq([2, 2])
  end

  it "puts the counters on an existing Army and makes it an Orc" do
    existing = Magic::Amass.call(source: spell, controller: p1, amount: 1)
    game.settle!
    expect(existing.type?("Orc")).to be(false)

    cast_spell

    expect(p1.creatures.by_type("Army").count).to eq(1)
    expect(existing.power).to eq(3)
    expect(existing.type?("Orc")).to be(true)
  end
end
