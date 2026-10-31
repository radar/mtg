# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DeceiveTheMessenger do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Deceive The Messenger", owner: p1) }
  let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def army = p1.creatures.find { _1.type?("Army") }

  def cast_on(target, spell = card)
    p1.hand.add(spell)
    p1.add_mana(blue: 1)
    p1.cast(card: spell) do |a|
      a.pay_mana(blue: 1)
      a.targeting(target)
    end
    game.stack.resolve!
    game.tick!
  end

  it "gives the target creature -3/-0 until end of turn" do
    cast_on(bear)
    expect([bear.power, bear.toughness]).to eq([-1, 2])
  end

  it "wears off at end of turn" do
    cast_on(bear)
    current_turn.end!
    current_turn.cleanup!
    game.tick!
    expect([bear.power, bear.toughness]).to eq([2, 2])
  end

  it "can target a creature you control" do
    mine = ResolvePermanent("Grizzly Bears", owner: p1)
    cast_on(mine)
    expect(mine.power).to eq(-1)
    expect(bear.power).to eq(2)
  end

  it "amasses Orcs 1" do
    cast_on(bear)
    expect(army.type?("Orc")).to eq(true)
    expect(army.colors).to include(:black)
    expect([army.power, army.toughness]).to eq([1, 1])
  end

  it "adds to an existing Army" do
    cast_on(bear)
    cast_on(bear, Card("Deceive The Messenger", owner: p1))
    expect(p1.creatures.count { _1.type?("Army") }).to eq(1)
    expect(army.power).to eq(2)
  end
end
