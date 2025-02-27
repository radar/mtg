require 'spec_helper'

RSpec.describe Magic::Cards::AcademyElite do
  include_context "two player game"

  context "ETB effects" do
    subject(:academy_elite) { Card("Academy Elite", owner: p1) }

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
          p1.cast(card: academy_elite) do
            _1.pay_mana(generic: { blue: 3 }, blue: 1)
          end
          game.stack.resolve!
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
          p1.cast(card: academy_elite) do
            _1.pay_mana(generic: { blue: 3 }, blue: 1)
          end
          game.stack.resolve!
          game.tick!

          permanent = p1.permanents.last
          expect(permanent.counters.first).to be_a(Magic::Counters::Plus1Plus1)
          expect(permanent.power).to eq(2)
          expect(permanent.toughness).to eq(2)
        end
      end
    end
  end

  context "activated ability" do
    let(:academy_elite) { ResolvePermanent("Academy Elite", owner: p1) }

    before do
      academy_elite.add_counter(counter_type: Magic::Counters::Plus1Plus1)
    end

    it "removes a +1/+1 counter, draws a card and discards a card" do
      expect(p1).to receive(:draw!)

      p1.add_mana(blue: 3)
      p1.activate_ability(ability: academy_elite.activated_abilities.first) do
        _1.pay_mana(generic: { blue: 2 }, blue: 1)
      end

      game.stack.resolve!
      game.tick!

      expect(academy_elite.counters.count).to eq(0)

      choice = game.choices.last
      expect(choice).to be_a(Magic::Choice::Discard)
      chosen_card = p1.hand.cards.first
      game.resolve_choice!(card: chosen_card)
      expect(p1.graveyard.cards).to include(chosen_card)
      # Academy Elite is in GY as has no counters, which makes it a 0/0, and so it died.
      expect(p1.graveyard.cards).to include(academy_elite.card)
    end
  end
end
