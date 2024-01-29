require "spec_helper"

RSpec.describe Magic::Cards::StormwingEntity do
  include_context "two player game"

  subject { Card("Stormwing Entity", owner: p1) }

  context "when no instant or sorcery has been cast this turn" do
    it "has no cost reduction" do
      expect(subject.cost.generic).to eq(3)
      expect(subject.cost.blue).to eq(2)
    end
  end

  context "when an instant or sorcery has been cast this turn" do
    before do
      p1.add_mana(red: 1)
      p1.cast(card: Card("Shock")) do
        _1.targeting(p2)
        _1.pay_mana(red: 1)
      end
    end

    it "has a cost reduction of 2 generic, 1 blue" do
      expect(subject.cost.generic).to eq(1)
      expect(subject.cost.blue).to eq(1)
    end
  end

  context "etb, scries two" do
    it "scry two" do
      cast_and_resolve(card: subject, player: p1)

      choice = game.choices.last
      expect(choice).to be_a(Magic::Choice::Scry)
      expect(choice.amount).to eq(2)
    end
  end

end
