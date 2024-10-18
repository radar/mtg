require 'spec_helper'

RSpec.describe Magic::Cards::ElvishArchdruid do
  include_context "two player game"

  subject! { ResolvePermanent("Elvish Archdruid", owner: p1) }
  let!(:lathril) { ResolvePermanent("Lathril, Blade Of The Elves", owner: p1) }

  context "static ability" do
    it "gives lathril +1/+1" do
      expect(lathril.power).to eq(3)
      expect(lathril.toughness).to eq(4)
    end

    it "does not give itself the boost" do
      expect(subject.power).to eq(2)
      expect(subject.toughness).to eq(2)
    end
  end

  context "mana ability" do
    def activate_ability
      p1.activate_ability(ability: subject.activated_abilities.first)
    end

    it "adds green mana" do
      activate_ability
      # 1 mana from the Archdruid, 1 from Lathril
      expect(p1.mana_pool[:green]).to eq(2)
    end
  end
end
