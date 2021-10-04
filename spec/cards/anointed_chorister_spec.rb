require 'spec_helper'

RSpec.describe Magic::Cards::AnointedChorister do
  let(:game) { Magic::Game.new }
  let(:p1) { game.add_player }
  subject { Card("Anointed Chorister", controller: p1) }

  context "triggered ability" do
    it "applies a buff of +3/+3" do
      expect(subject.activated_abilities.count).to eq(1)
      p1.add_mana(white: 5)
      p1.pay_and_activate_ability!({ generic: { white: 4 }, white: 1 }, subject.activated_abilities.first)
      expect(subject.power).to eq(4)
      expect(subject.toughness).to eq(4)
    end
  end
end
