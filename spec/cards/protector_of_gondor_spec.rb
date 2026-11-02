# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ProtectorOfGondor do
  include_context "two player game"

  def soldiers(player) = player.creatures.select { _1.token? && _1.type?("Soldier") }

  it "is a 3/3 Human Soldier" do
    card = Card("Protector Of Gondor")
    expect([card.base_power, card.base_toughness]).to eq([3, 3])
    expect(card.type?("Human")).to be(true)
    expect(card.type?("Soldier")).to be(true)
  end

  it "creates a 1/1 white Human Soldier token when it enters" do
    ResolvePermanent("Protector Of Gondor", owner: p1)
    game.settle!

    token = soldiers(p1).first
    expect(soldiers(p1).count).to eq(1)
    expect(token.type?("Human")).to be(true)
    expect(token.colors).to include(:white)
    expect([token.power, token.toughness]).to eq([1, 1])
  end

  it "does not create a token for the opponent" do
    ResolvePermanent("Protector Of Gondor", owner: p1)
    game.settle!

    expect(soldiers(p2)).to be_empty
  end
end
