# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PartyThrasher do
  include_context "two player game"

  let!(:thrasher) { ResolvePermanent("Party Thrasher", owner: p1) }

  # Entering the first main phase fires the trigger: its "may discard" choice is pending afterwards.
  before do
    go_to_main_phase!
    game.settle!
  end

  it "is a 1/4 Lizard Wizard" do
    expect([thrasher.power, thrasher.toughness]).to eq([1, 4])
  end

  describe "convoke for noncreature spells from exile" do
    let(:shock) { Card("Shock", owner: p1) }

    before { game.skip_choice! }

    it "lets you tap a creature to pay for a noncreature spell cast from exile" do
      shock.exile!
      game.play_permissions.grant_until_end_of_turn(card: shock, player: p1)

      p1.cast(card: shock) { |a| a.convoke(thrasher, pay: :red).targeting(p2) }
      game.stack.resolve!

      expect(thrasher).to be_tapped
      expect(p2.life).to eq(18)
    end

    it "does not give convoke to a spell cast from hand" do
      p1.hand.add(shock)
      action = cast_action_as(:normal, card: shock, player: p1)

      expect { action.convoke(thrasher, pay: :red) }.to raise_error(/does not have convoke/)
    end
  end

  describe "first main phase trigger" do
    it "asks whether to discard a card" do
      expect(game.choices.first).to be_a(Magic::Cards::PartyThrasher::MayDiscardChoice)
    end

    it "discards, exiles the top two cards, and lets you play the chosen one this turn" do
      exiled = p1.library.first(2)
      discarded = p1.hand.first
      game.resolve_choice!(card: discarded)
      game.resolve_choice!(target: exiled.first)

      expect(p1.graveyard.cards).to include(discarded)
      expect(game.exile.cards).to include(*exiled)
      expect(game.play_permissions.permits?(exiled.first, p1)).to be(true)
      expect(game.play_permissions.permits?(exiled.last, p1)).to be(false)
    end

    it "does nothing when declined" do
      library_size = p1.library.count
      game.skip_choice!

      expect(p1.library.count).to eq(library_size)
    end
  end
end
