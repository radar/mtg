# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::InquisitiveGlimmer do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:glimmer) { ResolvePermanent("Inquisitive Glimmer", owner: p1) }

  it "is a 2/3 Fox Glimmer enchantment creature" do
    expect([glimmer.power, glimmer.toughness]).to eq([2, 3])
    expect(glimmer.card).to be_enchantment
    expect(glimmer.card).to be_creature
  end

  describe "enchantment spells you cast cost {1} less" do
    it "reduces an enchantment spell" do
      sanctum = Card("Sanctum Of Calm Waters", owner: p1) # {3}{U}
      p1.hand.add(sanctum)
      p1.add_mana(blue: 3)

      p1.cast(card: sanctum) { _1.pay_mana(generic: { blue: 2 }, blue: 1) }
      game.stack.resolve!

      expect(p1.permanents.map(&:name)).to include("Sanctum of Calm Waters")
    end

    it "does not reduce a creature spell" do
      bears = Card("Grizzly Bears", owner: p1)
      p1.hand.add(bears)
      p1.add_mana(green: 1)

      expect { p1.cast(card: bears) { _1.pay_mana(green: 1) } }.to raise_error(Magic::Costs::Mana::CannotPay)
    end

    it "does not reduce an opponent's enchantment spell" do
      game.next_turn
      go_to_main_phase!
      sanctum = Card("Sanctum Of Calm Waters", owner: p2)
      p2.hand.add(sanctum)
      p2.add_mana(blue: 3)

      expect { p2.cast(card: sanctum) { _1.pay_mana(generic: { blue: 2 }, blue: 1) } }
        .to raise_error(Magic::Costs::Mana::CannotPay)
    end

    it "reduces the cost of casting a Room as a door" do
      room = Card("Funeral Room Awakening Hall", owner: p1) # Funeral Room costs {2}{B}
      p1.hand.add(room)
      p1.add_mana(black: 2)

      p1.cast(card: room, door: :left) { _1.pay_mana(generic: { black: 1 }, black: 1) }
      game.stack.resolve!

      expect(p1.rooms.size).to eq(1)
    end
  end

  describe "unlock costs you pay cost {1} less" do
    let!(:room) { ResolvePermanent("Funeral Room Awakening Hall", owner: p1, doors: [:left]) }

    it "reduces the cost to unlock a door" do
      p1.add_mana(black: 7)
      # Awakening Hall costs {6}{B}{B}; one less is {5}{B}{B}
      p1.unlock_door(permanent: room, door: :right) { _1.pay_mana(generic: { black: 5 }, black: 2) }

      expect(room.card).to be_fully_unlocked
    end

    it "does not reduce an opponent's unlock cost" do
      other = ResolvePermanent("Funeral Room Awakening Hall", owner: p2, doors: [:left])
      game.next_turn
      go_to_main_phase!
      p2.add_mana(black: 7)

      expect { p2.unlock_door(permanent: other, door: :right) { _1.pay_mana(generic: { black: 5 }, black: 2) } }
        .to raise_error(Magic::Costs::Mana::CannotPay)
    end
  end
end
