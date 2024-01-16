require 'spec_helper'

RSpec.describe Magic::Cards::LlanowarElves do
  include_context "two player game"

  subject { ResolvePermanent("Llanowar Elves", owner: p1) }

  context "when on battlefield" do
    it "can be tapped for one green mana" do
      ability = subject.activated_abilities.first
      p1.activate_ability(ability: ability)
      expect(p1.mana_pool[:green]).to eq(1)
    end
  end
end
