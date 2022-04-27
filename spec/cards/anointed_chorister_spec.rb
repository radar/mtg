require 'spec_helper'

RSpec.describe Magic::Cards::AnointedChorister do
  include_context "two player game"

  subject { Card("Anointed Chorister", controller: p1) }

  context "triggered ability" do
    it "applies a buff of +3/+3" do
      expect(subject.activated_abilities.count).to eq(1)
      p1.add_mana(white: 5)
      activation = p1.activate_ability(subject.activated_abilities.first)
      activation.pay(:mana, { generic: { white: 4 }, white: 1 })
      activation.activate!
      game.stack.resolve!
      expect(p1.mana_pool[:white]).to eq(0)
      expect(subject.power).to eq(4)
      expect(subject.toughness).to eq(4)
    end
  end
end
