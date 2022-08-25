require 'spec_helper'

RSpec.describe Magic::Cards::LlanowarElves do
  include_context "two player game"

  subject { ResolvePermanent("Llanowar Elves", controller: p1) }

  context "when on battlefield" do
    it "can be tapped for one green mana" do
      ability = subject.activated_abilities.first
      action = Magic::Actions::ActivateAbility.new(player: p1, permanent: subject, ability: ability)
      game.take_action(action)
      expect(p1.mana_pool[:green]).to eq(1)
    end
  end
end
