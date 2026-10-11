# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DazzlingTheaterPropRoom do
  include_context "two player game"

  context "Dazzling Theater" do
    let!(:room) { ResolvePermanent("Dazzling Theater Prop Room", doors: [:left]) }
    let!(:helper) { ResolvePermanent("Grizzly Bears", owner: p1) }

    before { go_to_main_phase! }

    it "gives creature spells you cast convoke" do
      spell = Card("Courser Of Kruphix", owner: p1) # {1}{G}{G}
      p1.hand.add(spell)
      p1.add_mana(green: 2)

      p1.cast(card: spell) do |action|
        action.convoke(helper)
        action.pay_mana(green: 2)
      end
      game.stack.resolve!

      expect(helper).to be_tapped
      expect(p1.creatures.map(&:name)).to include("Courser of Kruphix")
    end

    it "does not give convoke to noncreature spells" do
      spell = Card("Lightning Bolt", owner: p1)
      p1.hand.add(spell)
      p1.add_mana(red: 1)

      expect { p1.cast(card: spell) { _1.convoke(helper) } }.to raise_error(/does not have convoke/)
    end

    it "does not give convoke to your opponent" do
      spell = Card("Courser Of Kruphix", owner: p2)
      p2.hand.add(spell)

      expect { p2.cast(card: spell) { _1.convoke(helper) } }.to raise_error(/does not have convoke/)
    end

    it "gives nothing while the door is locked" do
      room.lock_door!(:left)
      spell = Card("Courser Of Kruphix", owner: p1)
      p1.hand.add(spell)

      expect { p1.cast(card: spell) { _1.convoke(helper) } }.to raise_error(/does not have convoke/)
    end
  end

  context "Prop Room" do
    let!(:room) { ResolvePermanent("Dazzling Theater Prop Room", doors: [:right]) }
    let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }

    def start_opponents_turn
      current_turn.end!
      current_turn.cleanup!
      game.next_turn
      current_turn.untap!
    end

    it "untaps each creature you control during each other player's untap step" do
      mine.tap!
      theirs.tap!
      start_opponents_turn

      expect(mine).not_to be_tapped
      expect(theirs).not_to be_tapped
    end

    it "does nothing while the door is locked" do
      room.lock_door!(:right)
      mine.tap!
      start_opponents_turn

      expect(mine).to be_tapped
    end

    it "removes a stun counter instead of untapping" do
      mine.tap!
      mine.add_counter("stun")
      start_opponents_turn

      expect(mine).to be_tapped
      expect(mine.counters.of_type(Magic::Counters::Stun).count).to eq(0)
    end
  end
end
