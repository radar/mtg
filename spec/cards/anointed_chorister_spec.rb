require 'spec_helper'

RSpec.describe Magic::Cards::AnointedChorister do
  include_context "two player game"

  subject { Card("Anointed Chorister", controller: p1) }

  context "triggered ability" do
    it "applies a buff of +3/+3" do
      expect(subject.activated_abilities.count).to eq(1)
      p1.add_mana(white: 5)
      activation = p1.prepare_to_activate(subject.activated_abilities.first)
      activation.pay({ generic: { white: 4 }, white: 1 })
      activation.activate!
      expect(subject.power).to eq(4)
      expect(subject.toughness).to eq(4)
    end
  end
end
