# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GlinTheMighty do
  include_context "two player game"

  context "as a creature" do
    let!(:gloin) { ResolvePermanent("Glóin The Mighty", owner: p1) }

    it "is a 4/3 legendary Dwarf Warrior" do
      expect([gloin.power, gloin.toughness]).to eq([4, 3])
      expect(gloin.type?("Dwarf")).to eq(true)
    end

    it "adds {R}{R} at the beginning of your first main phase" do
      go_to_main_phase!
      expect(p1.mana_pool[:red]).to eq(2)
    end

    it "doesn't add mana in the opponent's first main phase" do
      go_to_main_phase_for!(p2)
      expect(p1.mana_pool[:red]).to eq(0)
    end
  end

  context "as Easy Pickings" do
    let(:card) { Card("Glóin The Mighty", owner: p1) }
    let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }
    let!(:tough) { ResolvePermanent("Serra Angel", owner: p2) }
    let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }

    before do
      go_to_main_phase!
      p1.hand.add(card)
      p1.add_mana(red: 3)
      p1.cast(card:, adventure: true) { |a| a.pay_mana(generic: { red: 2 }, red: 1) }
      game.stack.resolve!
      game.settle!
    end

    it "deals 1 damage to each creature your opponents control" do
      expect(theirs.damage).to eq(1)
      expect(tough.damage).to eq(1)
      expect(mine.damage).to eq(0)
    end

    it "goes on an adventure, leaving the creature castable from exile" do
      expect(card.zone).to be_exile
    end
  end
end
