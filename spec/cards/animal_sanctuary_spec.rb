require "spec_helper"

RSpec.describe Magic::Cards::AnimalSanctuary do
  include_context "two player game"

  subject! { ResolvePermanent("Animal Sanctuary", owner: p1) }


  context "mana ability" do
    def activate_ability
      p1.activate_ability(ability: subject.activated_abilities.first)
    end

    it "adds one colorless mana" do
      activate_ability
      expect(p1.mana_pool[:generic]).to eq(1)
    end
  end

  context "counter ability" do
    let!(:rambunctious_mutt) { ResolvePermanent("Rambunctious Mutt", owner: p1) }
    before do
      ResolvePermanent("Wild Jhovall", owner: p1)
    end

    def activate_ability
      p1.add_mana(green: 2)
      p1.activate_ability(ability: subject.activated_abilities.last) do
        _1.pay_mana(generic: { green: 2 })
        _1.targeting(rambunctious_mutt)
      end
      game.stack.resolve!
    end

    it "puts a +1/+1 counter on target creature" do
      activate_ability
      expect(rambunctious_mutt.power).to eq(3)
      expect(rambunctious_mutt.toughness).to eq(3)
    end
  end
end
