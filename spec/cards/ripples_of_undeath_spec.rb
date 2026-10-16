# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RipplesOfUndeath do
  include_context "two player game"

  let!(:ripples) { ResolvePermanent("Ripples Of Undeath", owner: p1) }

  def first_main_phase!(player = p1)
    game.notify!(Magic::Events::FirstMainPhase.new(active_player: player))
    game.settle!
  end

  context "with mana to pay" do
    before { p1.add_mana(black: 1) }

    it "mills three cards at the beginning of your first main phase" do
      library = p1.library.count
      first_main_phase!

      expect(p1.graveyard.count).to eq(3)
      expect(p1.library.count).to eq(library - 3)
      expect(game.choices.first).to be_a(Magic::Choice::PayMana)
    end

    it "pays {1} and 3 life, then puts a milled card into your hand" do
      first_main_phase!
      hand = p1.hand.count
      game.resolve_choice!
      choice = game.choices.first
      expect(choice).to be_a(Magic::Choice::ReturnFromAmong)
      card = choice.choices.first
      game.resolve_choice!(target: card)

      expect(p1.mana_pool[:black]).to eq(0)
      expect(p1.life).to eq(17)
      expect(p1.hand.count).to eq(hand + 1)
      expect(card.zone).to eq(p1.hand)
      expect(p1.graveyard.count).to eq(2)
    end

    it "still puts a milled card into your hand when the pick is skipped" do
      first_main_phase!
      hand = p1.hand.count
      game.resolve_choice!
      game.skip_choice!

      expect(p1.hand.count).to eq(hand + 1)
      expect(p1.graveyard.count).to eq(2)
      expect(p1.life).to eq(17)
    end

    it "still puts a milled card into your hand when resolved without a target" do
      first_main_phase!
      hand = p1.hand.count
      game.resolve_choice!
      game.resolve_choice!

      expect(p1.hand.count).to eq(hand + 1)
      expect(p1.graveyard.count).to eq(2)
    end

    it "lets you take any one of the three milled cards, not two" do
      first_main_phase!
      game.resolve_choice!
      choice = game.choices.first

      expect(choice.choices.size).to eq(3)
      expect(choice.count).to eq(1)
      expect { choice.resolve!(targets: choice.choices.first(2)) }.to raise_error(ArgumentError)
    end

    it "does nothing more when you decline" do
      first_main_phase!
      hand = p1.hand.count
      game.skip_choice!

      expect(p1.mana_pool[:black]).to eq(1)
      expect(p1.life).to eq(20)
      expect(p1.hand.count).to eq(hand)
      expect(p1.graveyard.count).to eq(3)
      expect(game.choices).to be_empty
    end

    it "doesn't trigger in the opponent's first main phase" do
      first_main_phase!(p2)

      expect(p1.graveyard.count).to eq(0)
      expect(game.choices).to be_empty
    end
  end

  it "mills but offers no payment without {1}" do
    first_main_phase!

    expect(p1.graveyard.count).to eq(3)
    expect(game.choices).to be_empty
    expect(p1.life).to eq(20)
  end

  it "offers no payment with fewer than 3 life" do
    p1.add_mana(black: 1)
    p1.lose_life(18)
    first_main_phase!

    expect(p1.graveyard.count).to eq(3)
    expect(game.choices).to be_empty
    expect(p1.life).to eq(2)
  end
end
