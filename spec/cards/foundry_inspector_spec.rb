require 'spec_helper'

RSpec.describe Magic::Cards::FoundryInspector do
  include_context "two player game"

  let!(:foundry_inspector) { ResolvePermanent("Foundry Inspector", controller: p1) }

  it "permanent has a static ability" do
    ability = foundry_inspector.static_abilities.first
    expect(ability).to be_a(Magic::Abilities::Static::ReduceManaCost)
  end

  context "entering the battlefield adds a static ability" do
    it "adds a mana reduction ability" do
      ability = game.battlefield.static_abilities.first
      expect(ability).to be_a(Magic::Abilities::Static::ReduceManaCost)
    end
  end
end
