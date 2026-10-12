# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BelladonnaTook do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:belladonna) { ResolvePermanent("Belladonna Took", owner: p1) }

  def make_token(owner: p1)
    Magic::Tokens::HumanSoldier.new(game: game, owner: owner).resolve!
    game.settle!
  end

  it "is a 2/2 legendary Halfling Citizen" do
    expect([belladonna.power, belladonna.toughness]).to eq([2, 2])
    expect(belladonna.card.types).to include("Halfling", "Citizen")
  end

  it "gains 1 life the first time a token enters this turn" do
    make_token

    expect(p1.life).to eq(21)
  end

  it "draws a card the second time" do
    make_token
    hand = p1.hand.count
    make_token

    expect(p1.life).to eq(21)
    expect(p1.hand.count).to eq(hand + 1)
  end

  it "puts a +1/+1 counter on each creature you control the third time" do
    3.times { make_token }
    game.tick!

    expect([belladonna.power, belladonna.toughness]).to eq([3, 3])
    expect(p1.life).to eq(21)
  end

  it "does nothing the fourth time" do
    4.times { make_token }
    game.tick!

    expect([belladonna.power, belladonna.toughness]).to eq([3, 3])
  end

  it "starts over on a new turn" do
    make_token
    game.next_turn
    game.next_turn
    make_token

    expect(p1.life).to eq(22)
  end

  it "ignores tokens an opponent controls and nontoken creatures" do
    make_token(owner: p2)
    ResolvePermanent("Grizzly Bears", owner: p1)

    expect(p1.life).to eq(20)
  end
end
