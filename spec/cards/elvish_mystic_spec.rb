# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ElvishMystic do
  include_context "two player game"

  subject { ResolvePermanent("Elvish Mystic", owner: p1) }

  it "is a 1/1 Elf Druid" do
    expect(subject.power).to eq(1)
    expect(subject.toughness).to eq(1)
    expect(subject.card.types).to include("Elf")
    expect(subject.card.types).to include("Druid")
  end

  it "taps for one green mana" do
    p1.activate_ability(ability: subject.activated_abilities.first)
    expect(p1.mana_pool[:green]).to eq(1)
  end
end
