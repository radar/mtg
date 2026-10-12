# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SilvanReveler do
  include_context "two player game"

  before { go_to_main_phase! }

  def cast_reveler
    card = Card("Silvan Reveler", owner: p1)
    p1.hand.add(card)
    p1.add_mana(green: 3, blue: 1)
    p1.cast(card:) { |a| a.pay_mana(generic: { green: 2 }, green: 1, blue: 1) }
    game.stack.resolve!
    game.settle!
    card
  end

  it "is a 3/2 Elf Citizen" do
    reveler = ResolvePermanent("Silvan Reveler", owner: p1)
    expect([reveler.power, reveler.toughness]).to eq([3, 2])
  end

  context "when it enters" do
    it "draws then discards a card" do
      cast_reveler
      hand_size = p1.hand.count
      graveyard_before = p1.graveyard.count
      spell = Card("Grizzly Bears", owner: p1)
      p1.hand.add(spell)
      expect(game.choices.last).to be_a(described_class::DiscardChoice)
      game.resolve_choice!(card: spell)

      expect(p1.hand.count).to eq(hand_size)
      expect(p1.graveyard.count).to eq(graveyard_before + 1)
    end

    it "puts a discarded land onto the battlefield tapped" do
      cast_reveler
      land = Card("Forest", owner: p1)
      p1.hand.add(land)
      game.resolve_choice!(card: land)

      forest = p1.permanents.lands.find { _1.name == "Forest" }
      expect(forest).not_to be_nil
      expect(forest).to be_tapped
      expect(p1.graveyard.cards).not_to include(land)
    end

    it "leaves a discarded nonland card in the graveyard" do
      cast_reveler
      spell = Card("Grizzly Bears", owner: p1)
      p1.hand.add(spell)
      game.resolve_choice!(card: spell)

      expect(p1.graveyard.cards).to include(spell)
    end
  end

  context "from the graveyard" do
    let(:reveler) { Card("Silvan Reveler", owner: p1) }

    before { p1.graveyard.add(reveler) }

    it "returns to your hand when a land enters and you pay {1}{G}{U}" do
      p1.add_mana(green: 2, blue: 1)
      ResolvePermanent("Forest", owner: p1)
      game.settle!
      game.resolve_choice!(payment: { generic: { green: 1 }, green: 1, blue: 1 })

      expect(p1.hand.cards).to include(reveler)
      expect(p1.graveyard.cards).not_to include(reveler)
    end

    it "stays if you decline" do
      p1.add_mana(green: 2, blue: 1)
      ResolvePermanent("Forest", owner: p1)
      game.settle!
      game.skip_choice!

      expect(p1.graveyard.cards).to include(reveler)
    end

    it "doesn't offer the payment when you can't afford it" do
      ResolvePermanent("Forest", owner: p1)
      game.settle!

      expect(game.choices).to be_empty
    end

    it "doesn't trigger from a land an opponent controls" do
      p1.add_mana(green: 2, blue: 1)
      ResolvePermanent("Forest", owner: p2)
      game.settle!

      expect(game.choices).to be_empty
    end
  end
end
