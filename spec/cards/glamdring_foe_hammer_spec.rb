# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GlamdringFoeHammer do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Glamdring, Foe-Hammer", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  describe "the Equipment" do
    let!(:glamdring) { ResolvePermanent("Glamdring, Foe-Hammer", owner: p1) }

    it "is a legendary artifact Equipment" do
      expect(glamdring.types).to include(Magic::Types::Super::Legendary, Magic::Types::Artifact)
      expect(glamdring.card).to be_a(Magic::Cards::Equipment)
    end

    it "equips for {2}" do
      p1.add_mana(blue: 2)
      p1.activate_ability(ability: glamdring.activated_abilities.first) do |a|
        a.targeting(bears)
        a.pay_mana(generic: { blue: 2 })
      end
      game.stack.resolve!

      expect(glamdring.attached_to).to eq(bears)
    end

    context "when attached to a creature with power 2" do
      before { glamdring.attach_to!(bears) }

      it "makes an instant cost {2} less (here down to nothing extra)" do
        miscast = Card("Miscast", owner: p1) # {1}{U}
        p1.hand.add(miscast)
        p1.add_mana(blue: 1)
        game.tick!

        expect {
          p1.cast(card: miscast) { |a| a.pay_mana(blue: 1) }
        }.not_to raise_error
      end

      it "doesn't discount a creature spell" do
        wood_elves = Card("Wood Elves", owner: p1) # {2}{G}
        p1.hand.add(wood_elves)
        p1.add_mana(green: 1)
        game.tick!

        expect { p1.cast(card: wood_elves) { |a| a.pay_mana(green: 1) } }.to raise_error(StandardError)
      end
    end

    it "doesn't discount spells when it isn't attached" do
      miscast = Card("Miscast", owner: p1)
      p1.hand.add(miscast)
      p1.add_mana(blue: 1)

      expect { p1.cast(card: miscast) { |a| a.pay_mana(blue: 1) } }.to raise_error(StandardError)
    end
  end

  describe "Gleam of Death" do
    it "mills six, puts the instants and sorceries among them into your hand, and exiles the card" do
      p1.hand.add(card)
      p1.library.cards.clear
      opt = Card("Opt", owner: p1)
      miscast = Card("Miscast", owner: p1)
      five_bears = Array.new(4) { Card("Grizzly Bears", owner: p1) }
      [opt, miscast, *five_bears].each { |c| p1.library.add(c) }
      p1.add_mana(blue: 4)

      p1.cast(card:, adventure: true) { _1.pay_mana(generic: { blue: 3 }, blue: 1) }
      game.stack.resolve!
      game.settle!

      expect(p1.hand.cards).to include(opt, miscast)
      expect(p1.graveyard.cards).to include(*five_bears)
      expect(card.zone).to be_exile
    end
  end
end
