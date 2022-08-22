require 'spec_helper'

RSpec.describe Magic::Cards::HellkitePunisher do
  include_context "two player game"

  subject { ResolvePermanent("Hellkite Punisher", controller: p1) }

  it { is_expected.to be_flying }

  context "triggered ability" do
    it "activated ability increases power" do
      expect(subject.power).to eq(6)
      expect(subject.activated_abilities.count).to eq(1)
      p1.add_mana(red: 2)

      ability = subject.activated_abilities.first
      action = Magic::Actions::ActivateAbility.new(player: p1, permanent: subject, ability: ability)
      action.pay_mana(red: 1)
      game.take_action(action)
      game.stack.resolve!
      expect(subject.power).to eq(7)

      action = Magic::Actions::ActivateAbility.new(player: p1, permanent: subject, ability: ability)
      action.pay_mana(red: 1)
      game.take_action(action)
      game.stack.resolve!

      expect(subject.power).to eq(8)
      expect(subject.toughness).to eq(6)
    end
  end
end
