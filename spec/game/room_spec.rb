# frozen_string_literal: true

require "spec_helper"

# Two made-up Rooms exercise the engine's Room support (casting a door, unlocking, the unlock events).
module Magic
  module Cards
    class TestParlorTestCellar < Room
      class TestParlor < Room::Door
        card_name "Test Parlor"
        cost generic: 1, white: 1

        class GainLifeTrigger < Room::UnlockTrigger
          def call
            trigger_effect(:gain_life, target: controller, life: 2)
          end
        end

        def unlock_triggers = [GainLifeTrigger]
      end

      class TestCellar < Room::Door
        card_name "Test Cellar"
        cost generic: 2, black: 1

        class DrawTrigger < Room::UnlockTrigger
          def call
            trigger_effect(:draw_cards, number_to_draw: 1)
          end
        end

        def unlock_triggers = [DrawTrigger]
      end

      doors TestParlor, TestCellar
    end
  end
end

RSpec.describe Magic::Cards::Room do
  include_context "two player game"

  let(:room) { Card("Test Parlor Test Cellar") }

  before { go_to_main_phase! }

  # Test Parlor costs {1}{W}.
  def cast_parlor
    p1.hand.add(room)
    p1.add_mana(white: 2)
    p1.cast(card: room, door: :left) { |action| action.pay_mana(generic: { white: 1 }, white: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "has both halves' names, mana value and colours in hand" do
    expect(room.name).to eq("Test Parlor // Test Cellar")
    expect(room.mana_value).to eq(5)
    expect(room.colors).to contain_exactly(:white, :black)
    expect(room.types).to include(Magic::Types::Enchantment, "Room")
  end

  it "cannot be cast without choosing a door" do
    p1.hand.add(room)
    action = Magic::Actions::Cast.new(game: game, player: p1, card: room)
    expect(action.illegal_reason).to match(/cast as one of its doors/)
  end

  context "cast as its left door" do
    before { cast_parlor }

    let(:permanent) { p1.permanents.find { _1.card == room } }

    it "enters with only that door unlocked, with that door's characteristics" do
      expect(permanent).not_to be_nil
      expect(room.unlocked_doors.map(&:name)).to eq(["Test Parlor"])
      expect(permanent.name).to eq("Test Parlor")
      expect(permanent.mana_value).to eq(2)
      expect(permanent.colors).to eq([:white])
    end

    it "fires 'when you unlock this door' for the door it entered with" do
      expect(p1.life).to eq(22)
    end

    it "unlocks the other door by paying its cost, firing both unlock events" do
      p1.add_mana(black: 3)
      hand_size = p1.hand.cards.count
      p1.unlock_door(permanent:, door: :right) { |action| action.pay_mana(generic: { black: 2 }, black: 1) }
      game.settle!

      expect(room).to be_fully_unlocked
      expect(permanent.name).to eq("Test Parlor // Test Cellar")
      expect(permanent.mana_value).to eq(5)
      expect(game.current_turn.events.map(&:class)).to include(Magic::Events::DoorUnlocked, Magic::Events::RoomFullyUnlocked)
      expect(p1.hand.cards.count).to eq(hand_size + 1)
      # The Parlor's trigger is for the Parlor's unlocking only.
      expect(p1.life).to eq(22)
    end

    it "cannot unlock a door that is already unlocked" do
      unlock = Magic::Actions::UnlockDoor.new(game: game, player: p1, permanent: permanent, door: :left)
      expect(unlock.illegal_reason).to match(/already unlocked/)
    end

    it "forgets which doors were unlocked when it leaves the battlefield" do
      permanent.destroy!
      game.settle!
      expect(room.unlocked_doors).to be_empty
      expect(room.name).to eq("Test Parlor // Test Cellar")
    end
  end

  it "offers the unlock of a locked door as a legal action" do
    permanent = ResolvePermanent("Test Parlor Test Cellar", doors: [:left])
    p1.add_mana(black: 3)

    actions = game.legal_actions(p1)
    expect(actions.grep(Magic::Actions::UnlockDoor).map { _1.door.name }).to eq(["Test Cellar"])
    expect(permanent.card.locked_doors.map(&:name)).to eq(["Test Cellar"])
  end

  it "offers casting either door from hand" do
    p1.hand.add(room)
    p1.add_mana(white: 2, black: 3)

    casts = game.legal_actions(p1).grep(Magic::Actions::Cast).select { _1.card == room }
    expect(casts.size).to eq(2)
  end
end
