require 'spec_helper'

RSpec.describe Magic::Cards::SanctumOfTranquilLight do
  include_context "two player game"
  subject { ResolvePermanent("Sanctum Of Tranquil Light", controller: p1) }
  let!(:wood_elves) { ResolvePermanent("Wood Elves", controller: p2) }

  context "activated ability" do
    it "taps wood elves" do
      expect(subject.activated_abilities.count).to eq(1)
      p1.add_mana(white: 5)
      action = Magic::Actions::ActivateAbility.new(player: p1, permanent: subject, ability: subject.activated_abilities.first)
        .pay_mana(generic: { white: 4 }, white: 1)
        .targeting(wood_elves)
      game.take_action(action)
      game.stack.resolve!
      expect(wood_elves).to be_tapped
    end
  end
end
