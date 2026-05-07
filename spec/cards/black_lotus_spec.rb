# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Magic::Cards::BlackLotus do
  include_context "two player game"
  subject { ResolvePermanent("Black Lotus", owner: p1) }

  context "tap and sacrifice" do
    it "adds three mana of chosen color" do
      ability = subject.activated_abilities.first
      ability.choose(:green)
      p1.activate_ability(ability: ability)
      expect(p1.mana_pool[:green]).to eq(3)
    end

    it "sacrifices the artifact when activated" do
      ability = subject.activated_abilities.first
      ability.choose(:blue)
      expect {
        p1.activate_ability(ability: ability)
      }.to change { p1.permanents.count }.by(-1)
      expect(p1.graveyard.map(&:name)).to include("Black Lotus")
    end

    it "can add mana of different colors" do
      # Test red
      lotus = ResolvePermanent("Black Lotus", owner: p1)
      ability = lotus.activated_abilities.first
      ability.choose(:red)
      p1.activate_ability(ability: ability)
      expect(p1.mana_pool[:red]).to eq(3)

      # Test white
      lotus2 = ResolvePermanent("Black Lotus", owner: p1)
      ability2 = lotus2.activated_abilities.first
      ability2.choose(:white)
      p1.activate_ability(ability: ability2)
      expect(p1.mana_pool[:white]).to eq(3)
    end
  end
end
