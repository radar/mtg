require 'spec_helper'

RSpec.describe Magic::Cards::ArastaOfTheEndlessWeb do
  include_context "two player game"

  subject! { ResolvePermanent("Arasta Of The Endless Web") }

  context "whenever an opponent casts an instant or sorcery spell..." do
    it "does not trigger when p1 casts" do
      lightning_bolt = Card("Lightning Bolt", owner: p1)
      p1.hand.add(lightning_bolt)
      p1.add_mana(red: 1)
      p1.cast(card: lightning_bolt) do
        _1.pay_mana(red: 1)
        _1.targeting(p2)
      end

      game.stack.resolve!

      expect(creatures.count).to eq(1)
    end

    it "triggers when p2 casts" do
      lightning_bolt = Card("Lightning Bolt", owner: p2)
      p2.hand.add(lightning_bolt)
      p2.add_mana(red: 1)
      p2.cast(card: lightning_bolt) do
        _1.pay_mana(red: 1)
        _1.targeting(p1)
      end

      game.stack.resolve!

      expect(creatures.count).to eq(2)
      spider = creatures.by_name("Spider").first
      expect(spider).to be_a_token
      expect(spider.power).to eq(1)
      expect(spider.toughness).to eq(2)
      expect(spider.colors).to eq([:green])
      expect(spider).to have_keyword(:reach)
    end

    it "does not trigger when p2 casts wood elves" do
      wood_elves = Card("Wood Elves", owner: p2)
      p2.hand.add(wood_elves)
      p2.add_mana(green: 3)
      p2.cast(card: wood_elves) do
        _1.pay_mana(green: 1, generic: { green: 2 })
      end

      game.stack.resolve!

      expect(creatures.count).to eq(2)
    end
  end
end
