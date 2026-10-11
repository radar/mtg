# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KeysToTheHouse do
  include_context "two player game"

  def p1_library
    9.times.map { Card("Forest") } + [Card("Golgari Guildgate")]
  end

  let!(:keys) { ResolvePermanent("Keys To The House", owner: p1) }

  before { go_to_main_phase! }

  context "the basic land search" do
    it "searches for a basic land, reveals it and puts it into your hand, sacrificing the Keys" do
      p1.add_mana(green: 1)
      p1.activate_ability(ability: keys.activated_abilities.first) { _1.pay_mana(generic: { green: 1 }) }
      game.stack.resolve!

      choice = game.choices.last
      expect(choice).to be_a(described_class::BasicLandChoice)
      expect(choice.choices.map(&:name)).to all(eq("Forest"))
      game.resolve_choice!(target: choice.choices.first)

      expect(p1.hand.by_name("Forest")).not_to be_empty
      expect(keys.zone).to be_nil
    end
  end

  context "locking or unlocking a door" do
    let!(:room) { ResolvePermanent("Funeral Room Awakening Hall", owner: p1, doors: [:left]) }

    def activate!
      p1.add_mana(green: 3)
      p1.activate_ability(ability: keys.activated_abilities.last) { _1.pay_mana(generic: { green: 3 }) }
      game.stack.resolve!
    end

    # With a single Room the target is automatic, so the door is the first question.
    it "unlocks a locked door of the Room you control" do
      activate!
      locked_door = game.choices.last.choices.find { _1.name == "Awakening Hall" }
      game.resolve_choice!(door: locked_door)

      expect(room.card).to be_fully_unlocked
      expect(keys.zone).to be_nil
    end

    it "locks an unlocked door" do
      activate!
      unlocked_door = game.choices.last.choices.find { _1.name == "Funeral Room" }
      game.resolve_choice!(door: unlocked_door)

      expect(room.card.unlocked_doors).to be_empty
    end

    it "asks which Room when you control several, and only offers your own" do
      other = ResolvePermanent("Glassworks Shattered Yard", owner: p1, doors: [:left])
      ResolvePermanent("Meat Locker Drowned Diner", owner: p2, doors: [:left])
      activate!

      expect(game.choices.last.choices).to contain_exactly(room, other)
      game.resolve_choice!(target: other)
      game.resolve_choice!(door: game.choices.last.choices.find { _1.name == "Shattered Yard" })

      expect(other.card).to be_fully_unlocked
      expect(room.card.unlocked_doors.size).to eq(1)
    end

    it "is activated only as a sorcery" do
      game.next_turn
      go_to_main_phase!

      expect { p1.activate_ability(ability: keys.activated_abilities.last) { _1.pay_mana(generic: { green: 3 }) } }
        .to raise_error(StandardError)
    end

    it "does nothing when you control no Room" do
      room.destroy!
      game.settle!
      activate!

      expect(game.choices).to be_empty
    end
  end
end
