require 'spec_helper'

RSpec.describe Magic::Cards::FoundryInspector do
  let(:game) { Magic::Game.new }
  let(:p1) { game.add_player }
  let(:foundry_inspector) { Card("Foundry Inspector", controller: p1) }

  context "entering the battlefield adds a static ability" do
    it "adds a mana reduction ability" do
      foundry_inspector.entered_the_battlefield!
      ability = game.battlefield.static_abilities.first
      expect(ability).to be_a(Magic::Abilities::Static::ReduceManaCost)
    end
  end

  context "when this card's ability exists" do
    before do
      foundry_inspector.entered_the_battlefield!
    end

    context "leaving the battlefield" do
      it "clears the static ability" do
        foundry_inspector.left_the_battlefield!
        expect(game.battlefield.static_abilities.count).to eq(0)
      end
    end
  end
end
