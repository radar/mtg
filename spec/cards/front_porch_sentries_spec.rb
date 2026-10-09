# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FrontPorchSentries do
  include_context "two player game"

  let!(:sentries) { ResolvePermanent("Front Porch Sentries", owner: p1) }

  it "is a 2/2 Goblin Soldier" do
    expect(sentries.power).to eq(2)
    expect(sentries.toughness).to eq(2)
    expect(sentries.type?("Goblin")).to eq(true)
  end

  it "gives target opposing creature -1/-1 when it dies" do
    opp_bears = ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Grizzly Bears", owner: p1)

    sentries.destroy!
    game.settle!
    game.tick!

    expect(opp_bears.power).to eq(1)
    expect(opp_bears.toughness).to eq(1)
  end
end
