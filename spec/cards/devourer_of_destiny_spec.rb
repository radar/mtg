# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DevourerOfDestiny do
  include_context "two player game"

  let(:devourer) { Card("Devourer Of Destiny", owner: p1) }

  it "is a 6/6 devoid Eldrazi" do
    permanent = ResolvePermanent("Devourer Of Destiny", owner: p1)

    expect([permanent.power, permanent.toughness]).to eq([6, 6])
    expect(permanent).to be_colorless
  end

  describe "cast trigger" do
    before { go_to_main_phase! }

    it "exiles target permanent that's one or more colors" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      ResolvePermanent("Colossal Dreadmaw", owner: p2)
      ResolvePermanent("Spawn-Gang Commander", owner: p2)
      p1.hand.add(devourer)
      p1.add_mana(colorless: 7)
      p1.cast(card: devourer) { |a| a.pay_mana(generic: { colorless: 5 }, colorless: 2) }
      game.settle!
      game.resolve_choice!(target: bears)

      expect(game.exile.cards.map(&:name)).to include("Grizzly Bears")
      expect(p2.creatures.map(&:name)).not_to include("Grizzly Bears")
    end

    it "cannot target a colorless permanent" do
      commander = ResolvePermanent("Spawn-Gang Commander", owner: p2)
      p1.hand.add(devourer)
      p1.add_mana(colorless: 7)
      p1.cast(card: devourer) { |a| a.pay_mana(generic: { colorless: 5 }, colorless: 2) }
      game.settle!

      expect(game.choices).to be_empty
      expect(p2.creatures).to include(commander)
    end
  end

  describe "opening hand" do
    let(:card) { Card("Devourer Of Destiny", owner: p1) }

    before do
      p1.hand.add(card)
      game.add_choice(Magic::Choice::RevealFromOpeningHand.new(card: card))
    end

    def stock_library
      %w[Forest Island Swamp Mountain Plains].each { |name| p1.library.add(Card(name, owner: p1)) }
    end

    it "waits for the owner's first upkeep, then exiles all but one of the top four" do
      stock_library
      game.resolve_choice!

      expect(game.choices).to be_empty
      go_to_main_phase!
      game.settle!

      choice = game.choices.first
      expect(choice).to be_a(Magic::Cards::DevourerOfDestiny::TopFourChoice)
      kept = choice.looked_at.first
      game.resolve_choice!(target: kept)

      expect(game.exile.cards.size).to eq(3)
      expect(game.exile.cards).not_to include(kept)
      expect(p1.library.cards.to_a + p1.hand.cards.to_a).to include(kept)
    end

    it "does nothing when the reveal is declined" do
      stock_library
      game.skip_choice!
      game.next_turn
      game.next_turn
      game.settle!

      expect(game.exile.cards).to be_empty
    end
  end
end
