# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MastersCouncillors do
  include_context "two player game"

  let!(:councillors) { ResolvePermanent("Master's Councillors", owner: p1) }

  def fill_graveyard(player, count)
    count.times { Card("Forest", owner: player).tap { |c| player.graveyard.add(c) } }
  end

  it "is a 1/3 with vigilance" do
    expect(councillors.power).to eq(1)
    expect(councillors.toughness).to eq(3)
    expect(councillors.keywords).to include(Magic::Cards::Keywords::VIGILANCE)
  end

  it "gets +2/+0 for each graveyard with seven or more cards" do
    fill_graveyard(p1, 7)
    game.tick!
    expect(councillors.power).to eq(3)
    fill_graveyard(p2, 6)
    game.tick!
    expect(councillors.power).to eq(3)
    fill_graveyard(p2, 1)
    game.tick!
    expect(councillors.power).to eq(5)
    expect(councillors.toughness).to eq(3)
  end

  it "makes a target player mill three on your second draw each turn" do
    p1.draw!
    game.settle!
    expect(game.choices).to be_empty
    p1.draw!
    game.settle!
    expect { game.resolve_choice!(target: p2) }.to change { p2.graveyard.cards.count }.by(3)
  end

  it "does not trigger on an opponent's second draw" do
    2.times { p2.draw! }
    game.settle!
    expect(game.choices).to be_empty
  end
end
