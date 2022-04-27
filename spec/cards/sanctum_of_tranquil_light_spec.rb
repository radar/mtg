require 'spec_helper'

RSpec.describe Magic::Cards::SanctumOfTranquilLight do
  include_context "two player game"
  subject { Card("Sanctum Of Tranquil Light", controller: p1) }
  let(:wood_elves) { Card("Wood Elves", controller: p2) }

  context "activated ability" do
    before do
      game.battlefield.add(subject)
      game.battlefield.add(wood_elves)
    end

    it "taps wood elves" do
      expect(subject.activated_abilities.count).to eq(1)
      p1.add_mana(white: 5)
      ability = subject.activated_abilities.first
      activation = p1.activate_ability(ability).targeting(wood_elves)
      activation.pay(:mana, generic: { white: 4 }, white: 1)
      activation.activate!
      game.stack.resolve!
      expect(wood_elves).to be_tapped
    end
  end
end
