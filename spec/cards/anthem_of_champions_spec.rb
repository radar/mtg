# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AnthemOfChampions do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before { ResolvePermanent("Anthem Of Champions", owner: p1) }

  it "gives creatures you control +1/+1" do
    game.tick!
    expect([bears.power, bears.toughness]).to eq([3, 3])
  end

  it "doesn't affect opponents' creatures" do
    game.tick!
    expect([rival.power, rival.toughness]).to eq([2, 2])
  end
end
