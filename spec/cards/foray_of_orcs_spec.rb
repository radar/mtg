# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ForayOfOrcs do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Foray of Orcs", owner: p1) }

  def army = p1.creatures.find { _1.type?("Army") }

  def cast_foray(spell = card)
    p1.hand.add(spell)
    p1.add_mana(red: 4)
    p1.cast(card: spell) { _1.pay_mana(generic: { red: 3 }, red: 1) }
    game.stack.resolve!
    game.tick!
  end

  it "amasses Orcs 2, creating a 2/2 black Orc Army when you control no Army" do
    cast_foray
    expect(army.type?("Orc")).to eq(true)
    expect([army.power, army.toughness]).to eq([2, 2])
  end

  it "puts counters on an existing Army" do
    Magic::Amass.call(source: card, controller: p1, amount: 1, subtype: "Orc")
    game.tick!
    cast_foray
    expect(p1.creatures.count { _1.type?("Army") }).to eq(1)
    expect(army.power).to eq(3)
  end

  context "with opposing creatures" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
    let!(:ogre) { ResolvePermanent("Axegrinder Giant", owner: p2) }
    let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }

    it "offers only creatures an opponent controls" do
      cast_foray
      expect(game.choices.last.choices).to contain_exactly(bears, ogre)
    end

    it "deals damage equal to the Army's power to the target" do
      cast_foray
      game.resolve_choice!(target: bears)
      game.settle!
      expect(p2.creatures.map(&:name)).not_to include("Grizzly Bears")
      expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
      expect(ogre.damage).to eq(0)
    end

    it "uses the Army's power after counters, including an existing Army" do
      Magic::Amass.call(source: card, controller: p1, amount: 1, subtype: "Orc")
      game.tick!
      cast_foray
      game.resolve_choice!(target: ogre)
      game.settle!
      expect(ogre.damage).to eq(3)
    end

    it "does not offer a hexproof creature" do
      hexproof = ResolvePermanent("Spined Megalodon", owner: p2)
      cast_foray
      expect(game.choices.last.choices).not_to include(hexproof)
    end

    it "declining does nothing" do
      cast_foray
      game.skip_choice!
      expect(bears.damage).to eq(0)
      expect(ogre.damage).to eq(0)
    end
  end

  it "does not prompt when the opponent controls no creatures, but still amasses" do
    cast_foray
    expect(game.choices).to be_empty
    expect(army.power).to eq(2)
  end
end
