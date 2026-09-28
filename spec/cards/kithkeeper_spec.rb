# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Kithkeeper do
  include_context "two player game"

  it "creates a Kithkin token for each color among permanents you control when it enters" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Kithkeeper", owner: p1)

    tokens = p1.creatures.select(&:token?)
    expect(tokens.count).to eq(2) # green + white
    expect(tokens.first.name).to eq("Kithkin")
    expect(tokens.first.colors).to contain_exactly(:green, :white)
  end

  it "gets +3/+0 and flying by tapping three untapped creatures" do
    keeper = ResolvePermanent("Kithkeeper", owner: p1)
    helpers = 2.times.map { ResolvePermanent("Grizzly Bears", owner: p1) }
    p1.activate_ability(ability: keeper.activated_abilities.first) { |a| a.pay_multi_tap([keeper, *helpers]) }
    game.stack.resolve!
    game.tick!

    expect(keeper.power).to eq(6)
    expect(keeper.flying?).to eq(true)
    expect([keeper, *helpers]).to all(be_tapped)
  end
end
