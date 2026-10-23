# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ObstinateGargoyle do
  include_context "two player game"

  let!(:gargoyle) { ResolvePermanent("Obstinate Gargoyle", owner: p1) }

  it "is a 2/2 artifact creature with persist" do
    expect(gargoyle.power).to eq(2)
    expect(gargoyle.toughness).to eq(2)
    expect(gargoyle.type?("Artifact")).to be(true)
    expect(gargoyle.keywords).to include(Magic::Cards::Keywords::PERSIST)
  end

  it "doesn't fly while unmodified" do
    game.tick!

    expect(gargoyle.flying?).to be(false)
  end

  it "flies while modified" do
    gargoyle.add_counter("+1/+1")
    game.settle!
    game.tick!

    expect(gargoyle.flying?).to be(true)
  end

  it "returns with a -1/-1 counter when it dies, and flies since the counter modifies it" do
    gargoyle.destroy!
    game.settle!

    returned = p1.creatures.find { _1.name == "Obstinate Gargoyle" }
    expect(returned).not_to be_nil
    expect(returned.power).to eq(1)
    game.tick!
    expect(returned.flying?).to be(true)
  end
end
