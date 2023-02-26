require 'spec_helper'

RSpec.describe Magic::Cards::SolRing do
  include_context "two player game"
  subject { ResolvePermanent("Sol Ring", owner: p1) }

  context "tap" do
    it "taps for two colorless mana" do
      action = Magic::Actions::ActivateAbility.new(player: p1, permanent: subject, ability: subject.activated_abilities.first)
      action.pay_tap
      game.take_action(action)
      expect(p1.mana_pool[:colorless]).to eq(2)
    end
  end
end
