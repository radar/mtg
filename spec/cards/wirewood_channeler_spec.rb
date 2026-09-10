# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WirewoodChanneler do
  include_context "two player game"

  subject { ResolvePermanent("Wirewood Channeler", owner: p1) }

  it "is a 2/2 Elf Druid" do
    expect(subject.power).to eq(2)
    expect(subject.toughness).to eq(2)
    expect(subject.type?("Elf")).to be true
  end

  it "taps for X mana of any one color, where X is the number of Elves on the battlefield" do
    ResolvePermanent("Llanowar Elves", owner: p1)
    ResolvePermanent("Llanowar Elves", owner: p2)

    ability = subject.activated_abilities.first
    p1.activate_ability(ability: ability) { _1.choose(:green) }

    expect(p1.mana_pool[:green]).to eq(3)
  end
end
