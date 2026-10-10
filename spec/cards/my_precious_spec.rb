# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MyPrecious do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  describe "the Equipment" do
    let!(:precious) { ResolvePermanent("My Precious", owner: p1) }

    def equip(creature)
      p1.add_mana(colorless: 2)
      p1.activate_ability(ability: precious.activated_abilities.first) do |a|
        a.targeting(creature)
        a.pay_mana(generic: { colorless: 2 })
      end
      game.stack.resolve!
      game.settle!
      game.tick!
    end

    it "is a legendary artifact Equipment" do
      expect(precious.types).to include(Magic::Types::Super::Legendary, Magic::Types::Artifact)
      expect(precious.card).to be_a(Magic::Cards::Equipment)
    end

    it "equips for {2} and 2 life" do
      expect { equip(bears) }.to change { p1.life }.by(-2)

      expect(precious.attached_to).to eq(bears)
    end

    it "gives the equipped creature hexproof and makes it unblockable" do
      equip(bears)

      expect(bears).to have_keyword(:hexproof)
      expect(bears).to have_keyword(:cant_be_blocked)
    end

    it "doesn't grant anything to other creatures" do
      other = ResolvePermanent("Grizzly Bears", owner: p1)
      equip(bears)

      expect(other).not_to have_keyword(:hexproof)
    end
  end

  describe "Allure of Power" do
    let(:card) { Card("My Precious", owner: p1) }

    before { p1.hand.add(card) }

    it "sacrifices a creature as an additional cost, draws two cards and goes on an adventure" do
      p1.add_mana(black: 2)
      hand_before = p1.hand.count
      library_before = p1.library.count

      p1.cast(card:, adventure: true) do |a|
        a.pay_mana(generic: { black: 1 }, black: 1)
        a.pay_sacrifice(bears)
      end
      game.stack.resolve!
      game.settle!

      expect(p1.library.count).to eq(library_before - 2)
      expect(p1.hand.count).to eq(hand_before - 1 + 2)
      expect(p1.graveyard.cards.map(&:name)).to include("Grizzly Bears")
      expect(card.zone).to be_exile
    end

    it "can be cast at instant speed" do
      current_turn.end!
      p1.add_mana(black: 2)

      expect {
        p1.cast(card:, adventure: true) do |a|
          a.pay_mana(generic: { black: 1 }, black: 1)
          a.pay_sacrifice(bears)
        end
      }.not_to raise_error
    end
  end
end
