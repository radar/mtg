require "spec_helper"

RSpec.describe Magic::Cards::Prismite do
  include_context "two player game"

  subject!(:permanent) { ResolvePermanent("Prismite") }

  context "when Prismite is on the battlefield" do
    it "can add one mana of any color" do
      ability = permanent.activated_abilities.first
      p1.add_mana(blue: 2)
      p1.activate_ability(ability: ability) do
        _1.pay_mana(generic: { blue: 2 })
        _1.choose(:black)
      end

      expect(p1.mana_pool[:black]).to eq(1)
    end
  end
end
