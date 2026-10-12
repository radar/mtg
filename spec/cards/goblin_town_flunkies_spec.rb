# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GoblinTownFlunkies do
  include_context "two player game"

  def armies = p1.creatures.select { _1.types.include?("Army") }

  it "is a 1/1 with haste" do
    flunkies = ResolvePermanent("Goblin Town Flunkies", owner: p1)
    expect(flunkies.power).to eq(1)
    expect(flunkies.keywords).to include(Magic::Cards::Keywords::HASTE)
  end

  it "creates a 0/0 Goblin Army with a +1/+1 counter when you control no Army" do
    ResolvePermanent("Goblin Town Flunkies", owner: p1)
    expect(armies.size).to eq(1)
    expect(armies.first.power).to eq(1)
  end

  it "puts a counter on an existing Army instead of making another" do
    ResolvePermanent("Goblin Town Flunkies", owner: p1)
    ResolvePermanent("Goblin Town Flunkies", owner: p1)
    expect(armies.size).to eq(1)
    expect(armies.first.power).to eq(2)
  end
end
