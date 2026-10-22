# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SayItsName do
  include_context "two player game"

  before { go_to_main_phase! }

  describe "the spell" do
    let(:spell) { Card("Say Its Name", owner: p1).tap { p1.hand.add(_1) } }

    it "mills three cards, then may return a creature or land card from your graveyard to your hand" do
      bears = Card("Grizzly Bears", owner: p1).tap { p1.graveyard.add(_1) }
      p1.add_mana(green: 2)
      p1.cast(card: spell) { _1.pay_mana(generic: { green: 1 }, green: 1) }
      game.stack.resolve!
      game.settle!

      expect(p1.graveyard.cards.count).to be >= 5 # three milled, Grizzly Bears, and the spell
      choice = game.choices.last
      expect(choice.choices).to include(bears)
      expect(choice.choices.map(&:name)).to all(satisfy { %w[Grizzly\ Bears Forest].include?(_1) })
      game.resolve_choice!(target: bears)

      expect(bears.zone).to be_hand
    end

    it "may return nothing" do
      p1.add_mana(green: 2)
      p1.cast(card: spell) { _1.pay_mana(generic: { green: 1 }, green: 1) }
      hand_size = p1.hand.cards.count
      game.stack.resolve!
      game.settle!
      game.skip_choice!

      expect(p1.hand.cards.count).to eq(hand_size) # the spell left the hand when it was cast
    end
  end

  describe "the graveyard ability" do
    let!(:copies) { 3.times.map { Card("Say Its Name", owner: p1).tap { p1.graveyard.add(_1) } } }
    let!(:altanak) { Card("Altanak The Thrice Called", owner: p1) }

    def activate!(cards = copies)
      p1.activate_ability(ability: copies.first.graveyard_abilities.first) { _1.pay_exile_from_graveyard(cards) }
      game.stack.resolve!
      game.settle!
    end

    it "exiles this card and two other cards named Say Its Name" do
      p1.library.add(altanak)
      activate!

      expect(copies.map(&:zone)).to all(be_exile)
    end

    it "searches your library for Altanak, puts it onto the battlefield and shuffles" do
      p1.library.add(altanak)
      expect(p1.library).to receive(:shuffle!).and_call_original
      activate!
      game.resolve_choice!(target: altanak)

      expect(p1.permanents.map(&:card)).to include(altanak)
    end

    it "finds Altanak in your hand or graveyard too" do
      p1.hand.add(altanak)
      activate!
      expect(game.choices.last.choices).to eq([altanak])
      game.resolve_choice!(target: altanak)

      expect(p1.permanents.map(&:card)).to include(altanak)
    end

    it "finds nothing without Altanak" do
      activate!
      game.resolve_choice!(target: nil)

      expect(p1.creatures).to be_empty
    end

    it "needs three cards named Say Its Name, including itself" do
      expect { activate!(copies.first(2)) }.to raise_error(ArgumentError)
      other = Card("Grizzly Bears", owner: p1).tap { p1.graveyard.add(_1) }
      expect { activate!([copies[0], copies[1], other]) }.to raise_error(ArgumentError)
    end

    it "can only be activated as a sorcery" do
      game.next_turn
      go_to_main_phase!

      expect(copies.first.graveyard_abilities.first).not_to be_requirements_met
    end
  end
end
