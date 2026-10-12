# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CentralElevatorPromisingStairs do
  include_context "two player game"

  context "Central Elevator" do
    before { go_to_main_phase! }

    let(:grand_entryway) { Card("Grand Entryway Elegant Rotunda", owner: p1).tap { p1.library.add(_1) } }
    let(:meat_locker) { Card("Meat Locker Drowned Diner", owner: p1).tap { p1.library.add(_1) } }
    let(:bears) { Card("Grizzly Bears", owner: p1).tap { p1.library.add(_1) } }
    let!(:room) { ResolvePermanent("Central Elevator Promising Stairs", doors: [:right]) }

    def unlock_elevator
      p1.add_mana(blue: 4)
      p1.unlock_door(permanent: room, door: :left) { |a| a.pay_mana(generic: { blue: 3 }, blue: 1) }
      game.settle!
    end

    it "searches for a Room card and puts it into your hand" do
      grand_entryway
      meat_locker
      bears
      unlock_elevator

      expect(game.choices.last.choices.to_a).to contain_exactly(grand_entryway, meat_locker)
      game.resolve_choice!(targets: [meat_locker])

      expect(p1.hand.cards).to include(meat_locker)
    end

    it "cannot find a Room with the same name as a Room you control" do
      ResolvePermanent("Grand Entryway Elegant Rotunda", doors: [:left])
      grand_entryway
      meat_locker
      unlock_elevator

      expect(game.choices.last.choices.to_a).to contain_exactly(meat_locker)
    end

  end

  context "Promising Stairs" do
    let!(:room) { ResolvePermanent("Central Elevator Promising Stairs", doors: [:right]) }

    def start_upkeep
      current_turn.untap!
      current_turn.upkeep!
      game.settle!
    end

    def unlocked_rooms
      [
        "Grand Entryway Elegant Rotunda",
        "Derelict Attic Widows Walk",
        "Glassworks Shattered Yard",
      ].each { ResolvePermanent(_1, doors: %i[left right]) }
    end

    it "surveils 1 at the beginning of your upkeep" do
      start_upkeep

      expect(game.choices.last).to be_a(Magic::Choice::Surveil)
    end

    it "does not trigger at an opponent's upkeep" do
      game.next_turn
      start_upkeep

      expect(game.choices).to be_empty
    end

    it "wins the game with eight different names among unlocked doors" do
      unlocked_rooms
      ResolvePermanent("Meat Locker Drowned Diner", doors: [:left])
      start_upkeep

      # 6 from the three full Rooms + Meat Locker + Promising Stairs
      expect(p2).to be_lost
      expect(p1).not_to be_lost
    end

    it "does not win with seven names" do
      unlocked_rooms
      start_upkeep

      # 6 from the three full Rooms + Promising Stairs
      expect(p2).not_to be_lost
    end

    it "does not count a locked door" do
      unlocked_rooms
      ResolvePermanent("Meat Locker Drowned Diner", doors: [:left])
      room.lock_door!(:right)
      start_upkeep

      expect(p2).not_to be_lost
    end
  end
end
