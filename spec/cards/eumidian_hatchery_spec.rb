require "spec_helper"

RSpec.describe Magic::Cards::EumidianHatchery do
  include_context "two player game"

  it "creates flying Insects equal to its hatchling counters when it dies" do
    hatchery = ResolvePermanent("Eumidian Hatchery", owner: p1)
    2.times { p1.activate_ability(ability: hatchery.activated_abilities.first) }
    hatchery.sacrifice!

    expect(p1.creatures.by_name("Insect").count).to eq(2)
    expect(p1.creatures.by_name("Insect").all? { |insect| insect.has_keyword?(:flying) }).to be(true)
  end
end