require 'spec_helper'

RSpec.describe Magic::Cards::IgneousCur do
  include_context "two player game"

  subject { ResolvePermanent("Igneous Cur", owner: p1) }


  context "activated ability" do
    it "increases power by +2" do
      expect(subject.power).to eq(1)
      expect(subject.activated_abilities.count).to eq(1)
      p1.add_mana(red: 2)

      ability = subject.activated_abilities.first
      p1.activate_ability(ability: ability) do
        _1.pay_mana(red: 1, generic: { red: 1 })
      end
      game.tick!
      expect(subject.power).to eq(3)

      p1.add_mana(red: 2)
      p1.activate_ability(ability: ability) do
        _1.pay_mana(red: 1, generic: { red: 1 })
      end
      game.tick!

      expect(subject.power).to eq(5)
      expect(subject.toughness).to eq(2)
    end
  end
end
