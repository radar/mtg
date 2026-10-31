# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SurroundedByOrcs do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:spell) { Card("Surrounded By Orcs", owner: p1) }

  def army = p1.creatures.by_type("Army").first

  def cast_spell(target)
    p1.hand.add(spell)
    p1.add_mana(blue: 4)
    p1.cast(card: spell) { |a| a.pay_mana(generic: { blue: 3 }, blue: 1).targeting(target) }
    game.stack.resolve!
    game.settle!
  end

  it "is a {3}{U} sorcery" do
    expect(spell.cost.cost).to eq(generic: 3, blue: 1)
    expect(spell).to be_a(Magic::Cards::Sorcery)
  end

  it "amasses Orcs 3 creating a black Orc Army with three +1/+1 counters" do
    cast_spell(p2)

    expect(army.type?("Orc")).to be(true)
    expect(army.colors).to eq([:black])
    expect([army.power, army.toughness]).to eq([3, 3])
  end

  it "mills the target player for the Army's power" do
    before_count = p2.library.count
    cast_spell(p2)

    expect(p2.library.count).to eq(before_count - 3)
    expect(p2.graveyard.cards.count).to eq(3)
    expect(p1.graveyard.cards).to contain_exactly(spell)
  end

  it "mills for the whole Army's power when it already has counters" do
    Magic::Amass.call(source: spell, controller: p1, amount: 2)
    game.settle!
    before_count = p2.library.count
    cast_spell(p2)

    expect(army.power).to eq(5)
    expect(p2.library.count).to eq(before_count - 5)
  end

  it "can target yourself" do
    before_count = p1.library.count
    cast_spell(p1)

    expect(p1.library.count).to eq(before_count - 3)
  end

  it "mills only what the library holds" do
    p2.library.cards.drop(1).each { p2.library.remove(_1) }
    cast_spell(p2)

    expect(p2.library.count).to eq(0)
    expect(p2.graveyard.cards.count).to eq(1)
  end
end
