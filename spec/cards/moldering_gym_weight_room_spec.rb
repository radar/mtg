# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MolderingGymWeightRoom do
  include_context "two player game"

  before { go_to_main_phase! }

  def unlock(room, side, mana)
    p1.add_mana(**mana)
    p1.unlock_door(permanent: room, door: side) { _1.auto_pay }
    game.settle!
  end

  it "Moldering Gym fetches a basic land onto the battlefield tapped when unlocked" do
    swamp = Card("Swamp", owner: p1).tap { p1.library.add(_1) }
    room = ResolvePermanent("Moldering Gym Weight Room", doors: [:right])
    unlock(room, :left, green: 3)
    game.resolve_choice!(target: swamp)

    land = p1.permanents.find { _1.card == swamp }
    expect(land).to be_tapped
  end

  it "Weight Room manifests dread, then puts three +1/+1 counters on that creature" do
    room = ResolvePermanent("Moldering Gym Weight Room", doors: [:left])
    unlock(room, :right, green: 6)
    game.resolve_choice!(target: game.choices.last.choices.first)
    game.settle!

    manifested = p1.permanents.find(&:face_down?)
    expect([manifested.power, manifested.toughness]).to eq([5, 5])
  end

  it "Weight Room's counters go on that creature only" do
    other = ResolvePermanent("Grizzly Bears", owner: p1)
    room = ResolvePermanent("Moldering Gym Weight Room", doors: [:left])
    unlock(room, :right, green: 6)
    game.resolve_choice!(target: game.choices.last.choices.first)
    game.settle!

    expect(other.power).to eq(2)
  end
end
