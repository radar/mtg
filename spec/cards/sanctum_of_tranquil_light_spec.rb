require 'spec_helper'

RSpec.describe Magic::Cards::SanctumOfTranquilLight do
  include_context "two player game"
  subject { ResolvePermanent("Sanctum Of Tranquil Light", owner: p1) }
  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }

  context "activated ability" do
    it "taps wood elves" do
      expect(subject.activated_abilities.count).to eq(1)
      p1.add_mana(white: 5)
      p1.activate_ability(ability: subject.activated_abilities.first) do
        _1
          .pay_mana(generic: { white: 4 }, white: 1)
          .targeting(wood_elves)
      end
      game.stack.resolve!
      expect(wood_elves).to be_tapped
    end
  end
end
