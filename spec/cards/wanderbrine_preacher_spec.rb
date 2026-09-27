# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WanderbrinePreacher do
  include_context "two player game"

  let!(:preacher) { ResolvePermanent("Wanderbrine Preacher", owner: p1) }

  it "is a 2/2 merfolk cleric" do
    expect(preacher.card.types).to include("Merfolk", "Cleric")
    expect(preacher.power).to eq(2)
    expect(preacher.toughness).to eq(2)
  end

  it "gains its controller 2 life when it becomes tapped" do
    preacher.tap!
    game.settle!

    expect(p1.life).to eq(22)
  end
end
