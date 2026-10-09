# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GollumSilentSlinker do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Gollum Silent Slinker", owner: p1) }

  it "is a 4/3 legendary creature with menace" do
    gollum = ResolvePermanent("Gollum Silent Slinker", owner: p1)
    expect(gollum.power).to eq(4)
    expect(gollum.toughness).to eq(3)
    expect(gollum.keywords).to include(Magic::Cards::Keywords::MENACE)
  end

  describe "adventure: Meager Meal" do
    let!(:bear) { ResolvePermanent("Large Bear", owner: p1) }

    before do
      p1.hand.add(card)
      p1.add_mana(black: 1)
    end

    it "puts a +1/+1 counter on the creature, gains 2 life, and exiles the card" do
      p1.cast(card:, adventure: true) { |a| a.targeting(bear, p1).pay_mana(black: 1) }
      game.stack.resolve!
      expect(bear.power).to eq(6)
      expect(p1.life).to eq(22)
      expect(card.zone).to be_exile
    end

    it "allows no creature target" do
      p1.cast(card:, adventure: true) { |a| a.targeting(nil, p2).pay_mana(black: 1) }
      game.stack.resolve!
      expect(bear.power).to eq(5)
      expect(p2.life).to eq(22)
    end

    it "lets you cast Gollum from exile afterwards" do
      p1.cast(card:, adventure: true) { |a| a.targeting(bear, p1).pay_mana(black: 1) }
      game.stack.resolve!
      p1.add_mana(black: 4)
      p1.cast(card:) { |a| a.pay_mana(generic: { black: 3 }, black: 1) }
      game.stack.resolve!
      expect(p1.permanents.map(&:name)).to include("Gollum, Silent Slinker")
    end
  end
end
