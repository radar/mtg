require "spec_helper"

RSpec.describe Magic::Cards::TeferisProtoge do
  include_context "two player game"
  subject { ResolvePermanent("Teferi's Protoge") }

  context "activated ability" do
    it "activates the ability" do
      expect(p1).to receive(:draw!)
      p1.add_mana(blue: 2)
      p1.activate_ability(ability: subject.activated_abilities.first) do
        _1.pay_mana(generic: { blue: 1 }, blue: 1)
      end

      game.stack.resolve!

      choice = game.choices.last
      expect(choice).to be_a(Magic::Choice::Discard)
    end
  end
end
