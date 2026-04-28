# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ChromaticOrrery do
  include_context "two player game"

  subject(:orrery) { ResolvePermanent("Chromatic Orrery", owner: p1) }

  context "tap ability — {T}: Add {C}{C}{C}{C}{C}" do
    let(:tap_ability) { orrery.activated_abilities.first }

    it "adds 5 colorless mana to the controller's mana pool" do
      p1.activate_ability(ability: tap_ability)
      expect(p1.mana_pool[:colorless]).to eq(5)
    end
  end

  context "draw ability — {5},{T}: Draw a card for each color among permanents you control" do
    let(:draw_ability) { orrery.activated_abilities.last }

    context "with permanents of two different colors" do
      let!(:white_creature) { ResolvePermanent("Story Seeker", owner: p1) }
      let!(:green_creature) { ResolvePermanent("Grizzly Bears", owner: p1) }

      it "draws a card for each distinct color (2 colors = 2 cards)" do
        p1.add_mana(colorless: 5)
        hand_before = p1.hand.count

        p1.activate_ability(ability: draw_ability) do
          _1.pay_mana(generic: { colorless: 5 })
        end
        game.stack.resolve!

        expect(p1.hand.count).to eq(hand_before + 2)
      end
    end

    context "with only colorless permanents (just the orrery)" do
      it "draws no cards" do
        p1.add_mana(colorless: 5)
        hand_before = p1.hand.count

        p1.activate_ability(ability: draw_ability) do
          _1.pay_mana(generic: { colorless: 5 })
        end
        game.stack.resolve!

        expect(p1.hand.count).to eq(hand_before)
      end
    end

    context "with permanents sharing a color" do
      let!(:white1) { ResolvePermanent("Story Seeker", owner: p1) }
      let!(:white2) { ResolvePermanent("Story Seeker", owner: p1) }

      it "counts each color only once" do
        p1.add_mana(colorless: 5)
        hand_before = p1.hand.count

        p1.activate_ability(ability: draw_ability) do
          _1.pay_mana(generic: { colorless: 5 })
        end
        game.stack.resolve!

        expect(p1.hand.count).to eq(hand_before + 1)
      end
    end
  end

  context "static ability — you may spend mana as though it were mana of any color" do
    before { orrery }

    it "allows casting a white spell using blue mana" do
      story_seeker = Card("Story Seeker", owner: p1)
      p1.add_mana(blue: 2)

      expect do
        action = Magic::Actions::Cast.new(card: story_seeker, player: p1, game: game)
        action.pay_mana(generic: { blue: 1 }, blue: 1)
        action.perform
      end.not_to raise_error
    end

    it "does not grant the ability to opponents" do
      story_seeker = Card("Story Seeker", owner: p2)
      p2.add_mana(blue: 2)

      expect do
        action = Magic::Actions::Cast.new(card: story_seeker, player: p2, game: game)
        action.pay_mana(generic: { blue: 1 }, blue: 1)
        action.perform
      end.to raise_error(Magic::Costs::Mana::CannotPay)
    end
  end
end
