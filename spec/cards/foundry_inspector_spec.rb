require 'spec_helper'

RSpec.describe Magic::Cards::FoundryInspector do
  include_context "two player game"

  let(:foundry_inspector) { Card("Foundry Inspector", controller: p1) }

  context "entering the battlefield adds a static ability" do
    before do
      game.battlefield.add(foundry_inspector)
    end

    it "adds a mana reduction ability" do
      foundry_inspector.entered_the_battlefield!
      ability = game.battlefield.static_abilities.first
      expect(ability).to be_a(Magic::Abilities::Static::ReduceManaCost)
    end
  end
end
