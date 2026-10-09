# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AnUnexpectedParty do
  include_context "two player game"

  let(:card) { Card("An Unexpected Party", owner: p1) }

  before { p1.hand.add(card) }

  describe "the enchantment" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:elves) { ResolvePermanent("Wood Elves", owner: p1) }
    let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }

    it "gives creatures you control of the chosen type +2/+2" do
      ResolvePermanent("An Unexpected Party", owner: p1)
      game.resolve_choice!(creature_type: "Bear")
      game.tick!

      expect([bears.power, bears.toughness]).to eq([4, 4])
      expect([elves.power, elves.toughness]).to eq([1, 1])
      expect([theirs.power, theirs.toughness]).to eq([2, 2])
    end

    it "stops buffing when it leaves" do
      party = ResolvePermanent("An Unexpected Party", owner: p1)
      game.resolve_choice!(creature_type: "Bear")
      party.destroy!
      game.settle!
      game.tick!

      expect(bears.power).to eq(2)
    end
  end

  describe "At the Door" do
    before { go_to_main_phase! }

    def dwarves = p1.creatures.select { _1.token? && _1.type?("Dwarf") }

    it "creates X 2/2 red Dwarf tokens, then exiles on an adventure" do
      p1.add_mana(white: 1, red: 5)
      p1.cast(card:, adventure: true, value_for_x: 3) do |a|
        a.pay_mana(white: 1, generic: { red: 2 }, x: { red: 3 })
      end
      game.stack.resolve!
      game.settle!

      expect(dwarves.size).to eq(3)
      expect([dwarves.first.power, dwarves.first.toughness]).to eq([2, 2])
      expect(card.zone).to be_exile
      expect(card.on_adventure).to eq(true)
    end

    it "creates nothing for X = 0" do
      p1.add_mana(white: 1, red: 2)
      p1.cast(card:, adventure: true, value_for_x: 0) { |a| a.pay_mana(white: 1, generic: { red: 2 }) }
      game.stack.resolve!
      game.settle!

      expect(dwarves).to be_empty
    end
  end
end
