# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Six do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:six) { ResolvePermanent("Six", owner: p1) }

  it "has reach" do
    expect(six).to have_keyword(Magic::Keywords::REACH)
  end

  describe "attack trigger" do
    def attack
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(six, target: p2)
      current_turn.attackers_declared!
      game.settle!
    end

    it "mills three cards and offers a milled land" do
      forest = Card("Forest", owner: p1)
      p1.library.add(forest)
      attack

      expect(p1.graveyard.cards).to include(forest)
      choice = game.choices.last
      expect(choice).to be_a(described_class::LandToHandChoice)
      game.resolve_choice!(target: forest)

      expect(p1.hand.cards).to include(forest)
      expect(p1.graveyard.cards).not_to include(forest)
    end

    it "lets the player decline the land" do
      forest = Card("Forest", owner: p1)
      p1.library.add(forest)
      attack
      game.skip_choice!

      expect(p1.hand.cards).not_to include(forest)
    end
  end

  describe "retrace" do
    let!(:bears) { Card("Grizzly Bears", owner: p1) }
    let!(:forest) { Card("Forest", owner: p1) }

    before do
      p1.graveyard.add(bears)
      p1.hand.add(forest)
      p1.add_mana(green: 2)
    end

    it "casts a nonland permanent card from the graveyard by discarding a land" do
      p1.cast(card: bears) { |a| a.pay_mana(generic: { green: 1 }, green: 1).pay_discard(forest) }
      game.stack.resolve!

      expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
      expect(p1.graveyard.cards).to include(forest)
    end

    it "does not work on the opponent's turn" do
      game.next_turn
      go_to_main_phase_for!(p2)

      expect do
        p1.cast(card: bears) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
      end.to raise_error(Magic::IllegalAction)
    end
  end
end
