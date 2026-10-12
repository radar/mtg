# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CryptidInspector do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:inspector) { ResolvePermanent("Cryptid Inspector", owner: p1) }

  def manifest(owner, name)
    card = Card(name, owner: owner).tap { owner.library.add(_1) }
    game.manifest!(card, controller: owner).tap { game.settle! }
  end

  it "is a 2/3 Elf Warrior with vigilance" do
    expect([inspector.power, inspector.toughness]).to eq([2, 3])
    expect(inspector).to have_keyword(:vigilance)
  end

  it "gets a +1/+1 counter whenever a face-down permanent you control enters" do
    manifest(p1, "Grizzly Bears")

    expect([inspector.power, inspector.toughness]).to eq([3, 4])
  end

  it "gets a +1/+1 counter whenever a permanent you control is turned face up" do
    bears = manifest(p1, "Grizzly Bears")
    p1.add_mana(green: 2)
    p1.turn_face_up(permanent: bears) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    game.settle!

    expect(inspector.power).to eq(4)
  end

  it "gets a counter when it is itself turned face up" do
    manifested = manifest(p1, "Cryptid Inspector")
    p1.add_mana(green: 3)
    p1.turn_face_up(permanent: manifested) { |a| a.pay_mana(generic: { green: 2 }, green: 1) }
    game.settle!

    # The face-up Inspector counts its own turn face up (and the first Inspector counts both of the other's events)
    expect(manifested.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(1)
  end

  it "ignores the opponent's face-down permanents entering or turning face up" do
    bears = manifest(p2, "Grizzly Bears")
    game.next_turn
    go_to_main_phase!
    p2.add_mana(green: 2)
    p2.turn_face_up(permanent: bears) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    game.settle!

    expect(inspector.power).to eq(2)
  end

  it "ignores face-up permanents entering" do
    ResolvePermanent("Grizzly Bears", owner: p1)

    expect(inspector.power).to eq(2)
  end
end
