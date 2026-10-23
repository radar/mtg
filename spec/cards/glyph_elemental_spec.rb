# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GlyphElemental do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def cast_bestowed(target)
    p1.add_mana(white: 2)
    p1.cast_as(:bestowed, card: Card("Glyph Elemental", owner: p1)) { |a| a.pay_mana(generic: { white: 1 }, white: 1).targeting(target) }
  end

  def glyph = game.battlefield.permanents.find { _1.name == "Glyph Elemental" }

  def play_forest
    p1.hand.add(Card("Forest", owner: p1))
    p1.play_land(land: p1.hand.cards.last)
    game.settle!
  end

  before { go_to_main_phase! }

  it "gets a +1/+1 counter whenever a land enters under its controller's control" do
    ResolvePermanent("Glyph Elemental", owner: p1)
    play_forest

    expect(glyph.power).to eq(3)
    expect(glyph.toughness).to eq(3)
  end

  context "when bestowed" do
    before do
      cast_bestowed(bears)
      game.stack.resolve!
      game.settle!
      game.tick!
    end

    it "gives the enchanted creature nothing with no counters" do
      expect(glyph.attached_to).to eq(bears)
      expect(bears.power).to eq(2)
    end

    it "gives the enchanted creature +1/+1 for each +1/+1 counter on the Aura" do
      play_forest
      game.tick!

      expect(bears.power).to eq(3)
      expect(bears.toughness).to eq(3)
    end
  end
end
