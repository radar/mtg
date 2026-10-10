# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ShardmagesRescue do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before do
    p1.add_mana(white: 1)
    p1.cast(card: Card("Shardmage's Rescue", owner: p1)) { |a| a.pay_mana(white: 1).targeting(bears) }
    game.stack.resolve!
    game.settle!
    game.tick!
  end

  it "has flash" do
    expect(Card("Shardmage's Rescue", owner: p1).has_keyword?(:flash)).to eq(true)
  end

  it "gives the enchanted creature +1/+1" do
    expect([bears.power, bears.toughness]).to eq([3, 3])
  end

  it "gives hexproof the turn the Aura entered" do
    expect(bears).to be_hexproof
  end

  it "loses hexproof on a later turn but keeps the bonus" do
    2.times { game.next_turn }
    go_to_main_phase!
    game.tick!

    expect(bears).not_to be_hexproof
    expect([bears.power, bears.toughness]).to eq([3, 3])
  end
end
