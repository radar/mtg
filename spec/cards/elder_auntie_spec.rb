# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ElderAuntie do
  include_context "two player game"

  it "is a 2/2 Goblin Warlock" do
    auntie = ResolvePermanent("Elder Auntie", owner: p1)
    expect(auntie.power).to eq(2)
    expect(auntie.toughness).to eq(2)
    expect(auntie).to be_type("Goblin")
    expect(auntie).to be_type("Warlock")
  end

  it "creates a 1/1 black and red Goblin token when it enters" do
    ResolvePermanent("Elder Auntie", owner: p1)

    token = p1.creatures.find(&:token?)
    expect(token.name).to eq("Goblin")
    expect(token.power).to eq(1)
    expect(token.toughness).to eq(1)
    expect(token.colors).to contain_exactly(:black, :red)
    expect(token).to be_type("Goblin")
  end
end
