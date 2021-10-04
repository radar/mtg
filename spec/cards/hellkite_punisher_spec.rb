require 'spec_helper'

RSpec.describe Magic::Cards::HellkitePunisher do
  let(:game) { Magic::Game.new }
  let(:p1) { game.add_player }
  subject { Card("Hellkite Punisher", controller: p1) }

  it { is_expected.to be_flying }

  context "triggered ability" do
    it "activated ability increases power" do
      expect(subject.activated_abilities.count).to eq(1)
      p1.add_mana(red: 2)
      ability = subject.activated_abilities.first
      expect(subject.power).to eq(6)
      p1.pay_and_activate_ability!({ red: 1 }, ability)
      expect(subject.power).to eq(7)
      p1.pay_and_activate_ability!({ red: 1 }, ability)
      expect(subject.power).to eq(8)
      expect(subject.toughness).to eq(6)
    end
  end
end
