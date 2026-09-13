# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LlanowarTribe do
  include_context "two player game"

  subject!(:permanent) { ResolvePermanent("Llanowar Tribe", owner: p1) }

  it "is a 3/3" do
    expect(permanent.power).to eq(3)
    expect(permanent.toughness).to eq(3)
  end

  it "is an Elf Druid" do
    expect(permanent.type?("Elf")).to be true
    expect(permanent.type?("Druid")).to be true
  end

  context "when tapped for mana" do
    it "adds three green mana" do
      ability = permanent.activated_abilities.first
      p1.activate_ability(ability: ability)

      expect(permanent).to be_tapped
      expect(p1.mana_pool[:green]).to eq(3)
    end
  end
end
