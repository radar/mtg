require "spec_helper"

RSpec.describe Magic::Cards::PalladiumMyr do
  include_context "two player game"

  subject!(:permanent) { ResolvePermanent("Palladium Myr") }

  context "when Palladium Myr is on the battlefield" do
    it "adds two generic mana" do
      ability = permanent.activated_abilities.first
      p1.activate_mana_ability(ability: ability)

      expect(permanent).to be_tapped

      expect(p1.mana_pool[:generic]).to eq(2)
    end
  end
end
