require 'spec_helper'

RSpec.describe Magic::Cards::HellkitePunisher do
  include_context "two player game"

  subject { ResolvePermanent("Hellkite Punisher", owner: p1) }

  it { is_expected.to be_flying }

  context "triggered ability" do
    it "activated ability increases power" do
      expect(subject.power).to eq(6)
      expect(subject.activated_abilities.count).to eq(1)
      p1.add_mana(red: 2)

      ability = subject.activated_abilities.first
      p1.activate_ability(ability: ability) do
        _1.pay_mana(red: 1)
      end
      game.tick!
      expect(subject.power).to eq(7)

      p1.activate_ability(ability: ability) do
        _1.pay_mana(red: 1)
      end
      game.tick!

      expect(subject.power).to eq(8)
      expect(subject.toughness).to eq(6)
    end
  end
end
