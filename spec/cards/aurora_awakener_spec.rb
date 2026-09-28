# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AuroraAwakener do
  include_context "two player game"
  before { go_to_main_phase! }

  it "has trample" do
    expect(ResolvePermanent("Aurora Awakener", owner: p1).trample?).to eq(true)
  end

  context "when it enters" do
    let(:forest) { Card("Forest", owner: p1) }
    let(:bears) { Card("Grizzly Bears", owner: p1) }
    let(:shock) { Card("Shock", owner: p1) }

    before do
      ResolvePermanent("Alaborn Trooper", owner: p1)
      # Top of library: Shock, Grizzly Bears, Forest
      [forest, bears, shock].each { |card| p1.library.add(card) }

      card = Card("Aurora Awakener", owner: p1)
      p1.hand.add(card)
      p1.add_mana(green: 7)
      cast_and_resolve(card: card, player: p1) { |a| a.pay_mana(generic: { green: 6 }, green: 1) }
    end

    it "reveals until X permanent cards, X being the number of colors among permanents you control" do
      choice = game.choices.last
      expect(choice).to be_a(described_class::PutOntoBattlefieldChoice)
      # Alaborn Trooper (W) + Aurora Awakener (G) = 2
      expect(choice.revealed).to eq([shock, bears, forest])
      expect(choice.choices).to eq([bears, forest])
    end

    it "puts any number of the permanent cards onto the battlefield and the rest on the bottom" do
      game.resolve_choice!(cards: [bears])
      game.tick!

      expect(bears.zone).to be_a(Magic::Zones::Battlefield)
      expect(forest.zone).to eq(p1.library)
      expect(shock.zone).to eq(p1.library)
      expect(p1.library.to_a.last(2)).to contain_exactly(shock, forest)
    end

    it "may put none of them onto the battlefield" do
      game.resolve_choice!(cards: [])

      expect(bears.zone).to eq(p1.library)
      expect(p1.library.to_a.last(3)).to contain_exactly(shock, bears, forest)
    end
  end
end
