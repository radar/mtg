# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MirkwoodPathmaker do
  include_context "two player game"

  it "has power and toughness equal to the number of lands you control" do
    3.times { ResolvePermanent("Forest", owner: p1) }
    ResolvePermanent("Forest", owner: p2)
    pathmaker = ResolvePermanent("Mirkwood Pathmaker", owner: p1)
    game.tick!
    expect(pathmaker.power).to eq(3)
    expect(pathmaker.toughness).to eq(3)
    ResolvePermanent("Forest", owner: p1)
    game.tick!
    expect(pathmaker.power).to eq(4)
  end
end
