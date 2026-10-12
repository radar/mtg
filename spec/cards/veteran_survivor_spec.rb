# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VeteranSurvivor do
  include_context "two player game"

  let!(:survivor) { ResolvePermanent("Veteran Survivor", owner: p1) }

  def graveyard_cards(count)
    Array.new(count) { Card("Island", owner: p1).tap { p1.graveyard.add(_1) } }
  end

  before { go_to_main_phase! }

  def go_to_second_main
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.end_of_combat!
    current_turn.second_main!
    game.settle!
  end

  it "is a 2/1" do
    expect(survivor.power).to eq(2)
    expect(survivor.toughness).to eq(1)
  end

  it "does nothing in the second main phase if untapped" do
    graveyard_cards(2)
    go_to_second_main
    expect(game.choices).to be_empty
  end

  it "exiles a card from a graveyard if tapped" do
    cards = graveyard_cards(2)
    survivor.tap!
    go_to_second_main
    game.resolve_choice!(target: cards.first)
    expect(cards.first.zone).to eq(game.exile)
    expect(survivor.power).to eq(2)
  end

  it "can exile nothing" do
    graveyard_cards(1)
    survivor.tap!
    go_to_second_main
    game.skip_choice!
    expect(survivor.exiled_cards).to be_empty
  end

  it "gets +3/+3 and hexproof with three cards exiled with it" do
    graveyard_cards(3).each do |card|
      card.exile!
      survivor.exiled_cards << card
    end
    game.tick!
    expect(survivor.power).to eq(5)
    expect(survivor.toughness).to eq(4)
    expect(survivor).to be_hexproof
  end

  it "does not get the bonus with only two cards exiled" do
    graveyard_cards(2).each do |card|
      card.exile!
      survivor.exiled_cards << card
    end
    game.tick!
    expect(survivor.power).to eq(2)
    expect(survivor).not_to be_hexproof
  end
end
