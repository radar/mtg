# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GhostlyKeybearer do
  include_context "two player game"

  let!(:keybearer) { ResolvePermanent("Ghostly Keybearer", owner: p1) }
  let!(:room) { ResolvePermanent("Funeral Room Awakening Hall", owner: p1, doors: [:left]) }

  def hit_player!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(keybearer, target: p2)
    current_turn.attackers_declared!
    go_to_combat_damage!
    game.settle!
  end

  it "is a 3/3 flying Spirit" do
    expect([keybearer.power, keybearer.toughness]).to eq([3, 3])
    expect(keybearer).to have_keyword(:flying)
  end

  it "unlocks a locked door of a Room you control when it deals combat damage to a player" do
    hit_player!
    expect(game.choices.last).to be_a(Magic::Choice::UnlockDoor)
    game.resolve_choice!(target: room)

    expect(room.card).to be_fully_unlocked
    expect(game.current_turn.events.map(&:class)).to include(Magic::Events::RoomFullyUnlocked)
  end

  it "may unlock nothing" do
    hit_player!
    game.skip_choice!

    expect(room.card.locked_doors.size).to eq(1)
  end

  it "offers only Rooms you control that have a locked door" do
    ResolvePermanent("Glassworks Shattered Yard", owner: p1, doors: %i[left right])
    ResolvePermanent("Meat Locker Drowned Diner", owner: p2, doors: [:left])
    hit_player!

    expect(game.choices.last.choices).to eq([room])
  end

  it "asks which door when a Room has two locked doors" do
    both_locked = ResolvePermanent("Glassworks Shattered Yard", owner: p1, doors: [])
    room.card.unlock!(:right)
    hit_player!
    game.resolve_choice!(target: both_locked)

    pick = game.choices.last
    expect(pick).to be_a(Magic::Choice::SelectDoor)
    game.resolve_choice!(door: pick.choices.last)

    expect(both_locked.card.unlocked_doors.map(&:name)).to eq(["Shattered Yard"])
  end

  it "does nothing when it deals no combat damage to a player" do
    game.notify!(Magic::Events::CombatDamageDealt.new(source: keybearer, target: ResolvePermanent("Grizzly Bears", owner: p2), damage: 3))
    game.settle!

    expect(game.choices).to be_empty
  end
end
