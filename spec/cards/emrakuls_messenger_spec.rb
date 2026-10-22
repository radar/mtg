# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EmrakulsMessenger do
  include_context "two player game"

  let!(:messenger) { ResolvePermanent("Emrakul's Messenger", owner: p1) }

  def spawns(player) = player.creatures.select { _1.name == "Eldrazi Spawn" }

  it "is a devoid 2/1 flier" do
    expect(messenger.colors).to be_empty
    expect(messenger.power).to eq(2)
    expect(messenger.toughness).to eq(1)
    expect(messenger.has_keyword?(Magic::Cards::Keywords::FLYING)).to be(true)
  end

  it "creates a Spawn only on your second draw each turn" do
    p1.draw!
    game.settle!
    expect(spawns(p1).count).to eq(0)

    p1.draw!
    game.settle!
    expect(spawns(p1).count).to eq(1)

    p1.draw!
    game.settle!
    expect(spawns(p1).count).to eq(1)
  end

  it "does not trigger on an opponent's second draw" do
    2.times { p2.draw! }
    game.settle!

    expect(spawns(p1).count).to eq(0)
    expect(spawns(p2).count).to eq(0)
  end
end
