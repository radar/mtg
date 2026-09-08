require "spec_helper"

RSpec.describe Magic::Cards::CommandTower do
  include_context "two player game"

  subject { ResolvePermanent("Command Tower", owner: p1) }

  context "when commander identity is Golgari" do
    before { p1.add_commander(Card("Lathril, Blade Of The Elves", owner: p1)) }

    it "adds one mana of any color in your commander's color identity" do
      mana_ability = subject.activated_abilities.first

      expect(mana_ability.choices).to match_array([:black, :green])
    end
  end

  context "when commander identity is Azorius" do
    before { p1.add_commander(Card("Niambi, Esteemed Speaker", owner: p1)) }

    it "adds one mana of any color in your commander's color identity" do
      mana_ability = subject.activated_abilities.first

      expect(mana_ability.choices).to match_array([:white, :blue])
    end
  end
end
