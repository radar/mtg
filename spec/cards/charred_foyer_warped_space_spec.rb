# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CharredFoyerWarpedSpace do
  include_context "two player game"

  context "Charred Foyer" do
    let!(:room) { ResolvePermanent("Charred Foyer Warped Space", doors: [:left]) }

    it "exiles the top card of your library at your upkeep, and you may play it this turn" do
      top = p1.library.first
      current_turn.untap!
      current_turn.upkeep!
      game.settle!

      expect(top.zone).to be_exile
      expect(game.play_permissions.permits?(top, p1)).to be(true)
    end

    it "does nothing at the beginning of an opponent's upkeep" do
      game.next_turn
      top = p1.library.first
      current_turn.untap!
      current_turn.upkeep!
      game.settle!

      expect(top.zone).to be_library
    end

    it "does nothing while the door is locked" do
      room.lock_door!(:left)
      top = p1.library.first
      current_turn.untap!
      current_turn.upkeep!
      game.settle!

      expect(top.zone).to be_library
    end
  end

  context "Warped Space" do
    let!(:room) { ResolvePermanent("Charred Foyer Warped Space", doors: [:right]) }
    let(:first) { Card("Grizzly Bears", owner: p1) }
    let(:second) { Card("Grizzly Bears", owner: p1) }

    before do
      go_to_main_phase!
      [first, second].each(&:exile!)
      [first, second].each { game.play_permissions.grant_until_end_of_turn(card: _1, player: p1) }
    end

    def pays_nothing?(card)
      Magic::Actions::Cast.new(game: game, player: p1, card: card, pay_nothing: true).pays_nothing_instead?
    end

    it "lets you pay {0} for a spell cast from exile, once each turn" do
      expect(pays_nothing?(first)).to be(true)

      p1.cast(card: first, pay_nothing: true)
      game.stack.resolve!

      expect(p1.creatures.map(&:name)).to eq(["Grizzly Bears"])
      expect(pays_nothing?(second)).to be(false)
    end

    it "is not used unless you ask for it" do
      expect { p1.cast(card: first) }.to raise_error(Magic::Costs::Mana::OutstandingBalance)
    end

    it "is not offered for a spell cast from your hand" do
      card = Card("Grizzly Bears", owner: p1)
      p1.hand.add(card)

      expect(pays_nothing?(card)).to be(false)
    end

    it "is available again on the next turn" do
      p1.cast(card: first, pay_nothing: true)
      game.stack.resolve!
      current_turn.end!
      current_turn.cleanup!

      expect(pays_nothing?(second)).to be(true)
    end
  end
end
