# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LastLightOfDurinsDay do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:enchantment) { ResolvePermanent("Last Light Of Durin's Day", owner: p1) }

  def quest_counters = enchantment.counters.of_type(Magic::Counters["quest"]).count

  describe "Mountaincycling {2}" do
    it "searches for a Mountain card" do
      card = Card("Last Light Of Durin's Day", owner: p1)
      p1.hand.add(card)
      mountain = Card("Mountain", owner: p1)
      p1.library.add(mountain)
      p1.add_mana(red: 2)
      p1.cycle(card:) { _1.pay_mana(generic: { red: 2 }) }
      game.choices.last.resolve!(targets: [mountain])

      expect(card.zone).to be_graveyard
      expect(mountain.zone).to be_hand
    end
  end

  describe "whenever a Mountain you control enters" do
    it "puts a quest counter on it" do
      ResolvePermanent("Mountain", owner: p1)

      expect(quest_counters).to eq(1)
    end

    it "ignores non-Mountain lands and opponents' Mountains" do
      ResolvePermanent("Forest", owner: p1)
      ResolvePermanent("Mountain", owner: p2)

      expect(quest_counters).to eq(0)
    end

    it "sacrifices at six counters and puts a Dragon from the library onto the battlefield" do
      dragon = Card("Smaug The Magnificent", owner: p1)
      p1.library.add(dragon)

      6.times { ResolvePermanent("Mountain", owner: p1) }
      game.choices.last.resolve!(target: dragon)
      game.tick!

      expect(p1.graveyard.cards.map(&:name)).to include("Last Light of Durin's Day")
      expect(p1.creatures.map(&:name)).to include("Smaug the Magnificent")
    end

    it "can find the Dragon in hand" do
      dragon = Card("Smaug The Magnificent", owner: p1)
      p1.hand.add(dragon)

      6.times { ResolvePermanent("Mountain", owner: p1) }
      game.choices.last.resolve!(target: dragon)

      expect(p1.creatures.map(&:name)).to include("Smaug the Magnificent")
    end
  end
end
