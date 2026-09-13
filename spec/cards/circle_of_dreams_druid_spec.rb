require 'spec_helper'

RSpec.describe Magic::Cards::CircleOfDreamsDruid do
  include_context "two player game"

  subject { ResolvePermanent("Circle of Dreams Druid") }

  context "mana ability" do
    it "adds green mana for each creature" do
      p1.activate_ability(ability: subject.activated_abilities.first)
      expect(p1.mana_pool[:green]).to eq(1)
    end

    context "when there's another creature" do
      before do
        ResolvePermanent("Grizzly Bears")
      end
      it "adds green mana for each creature" do
        p1.activate_ability(ability: subject.activated_abilities.first)
        expect(p1.mana_pool[:green]).to eq(2)
      end
    end
  end
end
