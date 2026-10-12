# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SmokyLoungeMistySalon do
  include_context "two player game"

  describe "Smoky Lounge" do
    let!(:room) { ResolvePermanent("Smoky Lounge Misty Salon", doors: [:left]) }

    def first_main!
      current_turn.untap!
      current_turn.upkeep!
      current_turn.draw!
      current_turn.first_main!
      game.settle!
    end

    it "adds {R}{R} at the beginning of your first main phase" do
      first_main!

      expect(p1.mana_pool.values.sum + p1.restricted_mana.size).to eq(2)
    end

    it "lets you spend it to unlock a door" do
      first_main!
      other = ResolvePermanent("Moldering Gym Weight Room", doors: [:right])
      p1.add_mana(green: 1)
      p1.unlock_door(permanent: other, door: :left) { _1.pay_mana(generic: { red: 2 }, green: 1) }

      expect(other.card).to be_fully_unlocked
    end

    it "lets you spend it to cast a Room spell" do
      first_main!
      card = Card("Underwater Tunnel Slimy Aquarium", owner: p1).tap { p1.hand.add(_1) }
      p1.add_mana(blue: 2)
      # Slimy Aquarium costs {3}{U}: the restricted {R}{R} pays two of the generic.
      p1.cast(card: card, door: :right) { _1.pay_mana(generic: { red: 2, blue: 1 }, blue: 1) }
      game.stack.resolve!

      expect(card.zone).to be_battlefield
    end

    it "can't be spent on other spells" do
      first_main!
      bolt = Card("Lightning Bolt", owner: p1).tap { p1.hand.add(_1) }

      expect { p1.cast(card: bolt) { _1.pay_mana(red: 1).targeting(p2) } }.to raise_error(StandardError)
    end

    it "doesn't add mana at an opponent's first main phase" do
      game.next_turn
      current_turn.untap!
      current_turn.upkeep!
      current_turn.draw!
      current_turn.first_main!
      game.settle!

      expect(p1.restricted_mana).to be_empty
    end
  end

  describe "Misty Salon" do
    it "creates an X/X blue flying Spirit, X the unlocked doors among Rooms you control" do
      ResolvePermanent("Moldering Gym Weight Room", doors: %i[left right])
      room = ResolvePermanent("Smoky Lounge Misty Salon", doors: [:left])
      go_to_main_phase!
      p1.add_mana(blue: 4)
      p1.unlock_door(permanent: room, door: :right) { _1.auto_pay }
      game.settle!

      spirit = p1.creatures.find { _1.type?("Spirit") }
      expect([spirit.power, spirit.toughness]).to eq([4, 4])
      expect(spirit).to have_keyword(:flying)
      expect(spirit.colors).to eq([:blue])
    end
  end
end
