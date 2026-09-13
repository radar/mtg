# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GolgariFindbroker do
  include_context "two player game"

  subject { Card("Golgari Findbroker") }

  before { p1.add_mana(black: 2, green: 2) }

  def cast_findbroker
    p1.cast(card: subject) { |a| a.pay_mana(black: 2, green: 2) }
    game.stack.resolve!
  end

  context "with a permanent card in the graveyard" do
    let(:wood_elves) { Card("Wood Elves") }

    before { p1.graveyard.add(wood_elves) }

    it "is a 3/4 Elf Shaman" do
      cast_findbroker
      game.resolve_choice!(target: wood_elves)

      findbroker = game.battlefield.by_name("Golgari Findbroker").first
      expect(findbroker.power).to eq(3)
      expect(findbroker.toughness).to eq(4)
      expect(findbroker.type?("Elf")).to eq(true)
      expect(findbroker.type?("Shaman")).to eq(true)
    end

    it "returns it to hand" do
      cast_findbroker
      game.resolve_choice!(target: wood_elves)

      expect(wood_elves.zone).to eq(p1.hand)
    end
  end

  context "with multiple permanent cards in the graveyard" do
    let(:wood_elves) { Card("Wood Elves") }
    let(:forest) { Card("Forest") }

    before do
      p1.graveyard.add(wood_elves)
      p1.graveyard.add(forest)
    end

    it "lets the controller choose which one to return" do
      cast_findbroker
      game.resolve_choice!(target: forest)

      expect(forest.zone).to eq(p1.hand)
      expect(wood_elves.zone).to eq(p1.graveyard)
    end
  end

  context "with only a non-permanent card in the graveyard" do
    let(:lightning_bolt) { Card("Lightning Bolt") }

    before { p1.graveyard.add(lightning_bolt) }

    it "cannot target it, and no choice is offered" do
      cast_findbroker

      expect(game.choices).to be_empty
      expect(lightning_bolt.zone).to eq(p1.graveyard)
    end
  end

  context "with no cards in the graveyard" do
    it "does not offer a choice" do
      cast_findbroker

      expect(game.choices).to be_empty
    end
  end
end
