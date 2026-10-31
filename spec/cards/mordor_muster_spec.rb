# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MordorMuster do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Mordor Muster", owner: p1) }

  def army = p1.creatures.find { _1.type?("Army") }

  def cast_muster(spell = card)
    p1.hand.add(spell)
    p1.add_mana(black: 2)
    p1.cast(card: spell) { _1.pay_mana(generic: { black: 1 }, black: 1) }
    game.stack.resolve!
    game.tick!
  end

  it "makes you draw a card and lose 1 life" do
    cast_muster
    expect(p1.life).to eq(19)
    expect(p2.life).to eq(20)
  end

  it "draws exactly one extra card" do
    library = p1.library.count
    cast_muster
    expect(p1.library.count).to eq(library - 1)
  end

  it "amasses Orcs 1, creating a black 1/1 Orc Army when you control no Army" do
    cast_muster
    expect(army.type?("Orc")).to eq(true)
    expect(army.type?("Goblin")).to eq(false)
    expect(army.colors).to include(:black)
    expect([army.power, army.toughness]).to eq([1, 1])
  end

  it "puts a counter on the Army you already control instead of making another" do
    cast_muster
    cast_muster(Card("Mordor Muster", owner: p1))
    expect(p1.creatures.count { _1.type?("Army") }).to eq(1)
    expect(army.power).to eq(2)
  end

  it "makes an existing Goblin Army also an Orc" do
    Magic::Amass.call(source: card, controller: p1, amount: 1)
    game.tick!
    expect(army.type?("Orc")).to eq(false)
    cast_muster
    expect(army.type?("Orc")).to eq(true)
    expect(army.power).to eq(2)
  end

  it "does not give the opponent an Army" do
    cast_muster
    expect(p2.creatures.any? { _1.type?("Army") }).to eq(false)
  end
end
