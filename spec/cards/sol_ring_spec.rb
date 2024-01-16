require 'spec_helper'

RSpec.describe Magic::Cards::SolRing do
  include_context "two player game"
  subject { ResolvePermanent("Sol Ring", owner: p1) }

  context "tap" do
    it "taps for two colorless mana" do
      p1.activate_ability(ability: subject.activated_abilities.first)
      expect(p1.mana_pool[:colorless]).to eq(2)
    end
  end
end
