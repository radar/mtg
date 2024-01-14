require 'spec_helper'

RSpec.describe Magic::Cards::AcademyElite do
  include_context "two player game"

  subject(:academy_elite) { Card("Academy Elite") }

  before do
    p1.hand.add(subject)
  end

  context "when there's a single instant in opponent's graveyard" do
    before do
      p2.graveyard.add(Card("Shock"))
    end

    context "when it enters the battlefield" do
      it "gets 1 +1/+1 counter" do
        p1.add_mana(blue: 4)
        action = Magic::Actions::Cast.new(player: p1, card: academy_elite)
        action.pay_mana(generic: { blue: 3 }, blue: 1)
        game.take_action(action)
        game.tick!

        permanent = p1.permanents.last
        expect(permanent.counters.first).to be_a(Magic::Counters::Plus1Plus1)
        expect(permanent.power).to eq(1)
        expect(permanent.toughness).to eq(1)
      end
    end
  end

  context "when there's an instant and sorcery in opponent's graveyard" do
    before do
      p2.graveyard.add(Card("Shock"))
      p2.graveyard.add(Card("Legion's Judgement"))
    end

    context "when it enters the battlefield" do
      it "gets 2 +1/+1 counters" do
        p1.add_mana(blue: 4)
        action = Magic::Actions::Cast.new(player: p1, card: academy_elite)
        action.pay_mana(generic: { blue: 3 }, blue: 1)
        game.take_action(action)
        game.tick!

        permanent = p1.permanents.last
        expect(permanent.counters.first).to be_a(Magic::Counters::Plus1Plus1)
        expect(permanent.power).to eq(2)
        expect(permanent.toughness).to eq(2)

      end
    end
  end

  it "activated ability to loot a card"
end
