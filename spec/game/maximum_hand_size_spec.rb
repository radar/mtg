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
    expect(discards.count).to eq(2)
    expect(discards.map(&:player)).to all(eq(p1))
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

    expect(game.choices.count { _1.is_a?(Magic::Choice::Discard) }).to eq(2)
  end
end
