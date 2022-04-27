require 'spec_helper'

RSpec.describe Magic::Cards::LlanowarElves do
  include_context "two player game"

  subject { Card("Llanowar Elves", controller: p1) }

  context "when on battlefield" do
    before do
      game.battlefield.add(subject)
    end

    it "can be tapped for one green mana" do
      ability = subject.activated_abilities.first
      activation = p1.activate_ability(ability)
      activation.activate!
      game.stack.resolve!
      expect(p1.mana_pool[:green]).to eq(1)
    end
  end
end
