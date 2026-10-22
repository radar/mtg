# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CharitableLevy do
  include_context "two player game"

  let!(:levy) { ResolvePermanent("Charitable Levy", owner: p1) }

  def collection = levy.counters.count

  # Sol Ring costs {1}; with the Levy tax it takes two mana.
  def cast_artifact(player)
    card = Card("Sol Ring", owner: player)
    player.hand.add(card)
    player.add_mana(white: 2)
    player.cast(card: card) { |a| a.pay_mana(generic: { white: 2 }) }
    card
  end

  before { go_to_main_phase! }

  describe "tax" do
    it "makes a noncreature spell cost {1} more" do
      ring = Card("Sol Ring", owner: p1)
      p1.hand.add(ring)
      p1.add_mana(white: 1)

      expect {
        p1.cast(card: ring) { |a| a.pay_mana(generic: { white: 1 }) }
      }.to raise_error(Magic::Costs::Mana::CannotPay)
    end

    it "lets a noncreature spell be cast with the extra {1} paid" do
      cast_artifact(p1)
      game.stack.resolve!

      expect(p1.artifacts.map(&:name)).to include("Sol Ring")
    end

    it "doesn't tax creature spells" do
      bears = Card("Grizzly Bears", owner: p1)
      p1.hand.add(bears)
      p1.add_mana(green: 2)
      p1.cast(card: bears) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
      game.stack.resolve!

      expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
      expect(collection).to eq(0)
    end

    it "taxes the opponent's noncreature spells too" do
      go_to_main_phase_for!(p2)
      ring = Card("Sol Ring", owner: p2)
      p2.hand.add(ring)
      p2.add_mana(white: 1)

      expect {
        p2.cast(card: ring) { |a| a.pay_mana(generic: { white: 1 }) }
      }.to raise_error(Magic::Costs::Mana::CannotPay)
    end
  end

  describe "collection counters" do
    it "gets a counter when you cast a noncreature spell" do
      cast_artifact(p1)
      game.settle!

      expect(collection).to eq(1)
    end

    it "gets a counter when an opponent casts a noncreature spell" do
      go_to_main_phase_for!(p2)
      cast_artifact(p2)
      game.settle!

      expect(collection).to eq(1)
    end

    it "gets no counter for a creature spell" do
      bears = Card("Grizzly Bears", owner: p1)
      p1.hand.add(bears)
      p1.add_mana(green: 2)
      p1.cast(card: bears) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
      game.settle!

      expect(collection).to eq(0)
    end
  end

  describe "third counter" do
    let!(:plains) { Card("Plains", owner: p1) }
    let!(:island) { Card("Island", owner: p1) }

    before do
      p1.library.add(plains)
      p1.library.add(island)
      2.times do
        cast_artifact(p1)
        game.stack.resolve!
        game.settle!
      end
    end

    it "doesn't sacrifice before the third counter" do
      expect(collection).to eq(2)
      expect(p1.enchantments).to include(levy)
    end

    it "sacrifices it, draws a card and offers a Plains search" do
      hand = p1.hand.count
      cast_artifact(p1)
      game.settle!

      expect(p1.enchantments).not_to include(levy)
      expect(p1.graveyard.cards.map(&:name)).to include("Charitable Levy")
      expect(p1.hand.cards).to include(island)
      # The Sol Ring was cast (it is on the stack, not in hand), so only the trigger's draw changes the hand.
      expect(p1.hand.count).to eq(hand + 1)

      choice = game.choices.last
      expect(choice).to be_a(Magic::Choice::SearchLibrary)
      expect(choice.choices).to include(plains)
      expect(choice.choices).not_to include(island)
    end

    it "puts the chosen Plains onto the battlefield tapped" do
      cast_artifact(p1)
      game.settle!
      expect(p1).to receive(:shuffle!).and_call_original
      game.resolve_choice!(targets: [plains])
      game.settle!

      expect(p1.lands.map(&:card)).to include(plains)
      expect(p1.lands.find { _1.card == plains }).to be_tapped
    end

    it "lets you decline the search" do
      cast_artifact(p1)
      game.settle!
      expect(p1).to receive(:shuffle!).and_call_original
      game.skip_choice!
      game.settle!

      expect(p1.lands).to be_empty
      expect(p1.library.cards).to include(plains)
    end

    it "does nothing if it's gone before the third trigger resolves" do
      hand = p1.hand.count
      cast_artifact(p1)
      levy.destroy!
      game.settle!

      expect(collection).to eq(2)
      expect(p1.hand.count).to eq(hand)
      expect(game.choices).to be_empty
    end

    it "sacrifices when an opponent casts the third spell, and its controller draws and searches" do
      go_to_main_phase_for!(p2)
      hand = p1.hand.count
      cast_artifact(p2)
      game.settle!

      expect(p1.enchantments).not_to include(levy)
      expect(p1.hand.count).to eq(hand + 1)
      expect(game.choices.last.actor.controller).to eq(p1)
    end
  end
end
