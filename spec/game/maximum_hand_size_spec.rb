# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Maximum hand size (rule 514.1)" do
  include_context "two player game"

  def end_turn!
    current_turn.end!
    current_turn.cleanup!
  end

  def fill_hand(player, count)
    player.hand.add(Card("Forest", owner: player)) while player.hand.count < count
  end

  it "has a maximum hand size of seven" do
    expect(p1.maximum_hand_size).to eq(7)
  end

  it "makes the active player discard down to seven in the cleanup step" do
    fill_hand(p1, 9)
    end_turn!

    discards = game.choices.select { _1.is_a?(Magic::Choice::Discard) }
    expect(discards.count).to eq(1)
    expect(discards.first.player).to eq(p1)
    expect(discards.first.amount).to eq(2)
  end

  it "lets the player discard several cards at once" do
    fill_hand(p1, 10)
    end_turn!
    discarded = p1.hand.first(3)
    game.resolve_choice!(cards: discarded)

    expect(p1.hand.count).to eq(7)
    expect(game.choices).to be_empty
  end

  it "asks again for what is left when the player picks fewer cards than needed" do
    fill_hand(p1, 10)
    end_turn!
    game.resolve_choice!(cards: p1.hand.first(1))

    expect(p1.hand.count).to eq(9)
    expect(game.choices.map(&:amount)).to eq([2])
  end

  it "refuses more cards than needed" do
    fill_hand(p1, 8)
    end_turn!

    expect { game.resolve_choice!(cards: p1.hand.first(2)) }.to raise_error(ArgumentError)
    expect(game.choices.count).to eq(1)
  end

  it "discards the card the player picks" do
    fill_hand(p1, 8)
    end_turn!
    discarded = p1.hand.first
    game.resolve_choice!(card: discarded)

    expect(p1.hand.count).to eq(7)
    expect(discarded.zone).to be_graveyard
  end

  it "asks for nothing at exactly seven cards" do
    fill_hand(p1, 7)
    end_turn!

    expect(game.choices).to be_empty
  end

  it "only affects the active player" do
    fill_hand(p2, 10)
    end_turn!

    expect(game.choices).to be_empty
  end

  it "has no limit with Niv-Mizzet, Visionary on the battlefield" do
    ResolvePermanent("Niv-Mizzet, Visionary", owner: p1)
    fill_hand(p1, 10)
    end_turn!

    expect(p1.maximum_hand_size).to be_nil
    expect(game.choices).to be_empty
    expect(p1.hand.count).to eq(10)
  end

  it "doesn't let an opponent's Niv-Mizzet lift your limit" do
    ResolvePermanent("Niv-Mizzet, Visionary", owner: p2)
    fill_hand(p1, 9)
    end_turn!

    expect(game.choices.sum { _1.is_a?(Magic::Choice::Discard) ? _1.amount : 0 }).to eq(2)
  end
end
