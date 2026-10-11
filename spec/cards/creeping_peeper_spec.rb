# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CreepingPeeper do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:peeper) { ResolvePermanent("Creeping Peeper", owner: p1) }

  def make_mana!
    p1.activate_ability(ability: peeper.activated_abilities.first)
  end

  it "is a 2/1 Eye" do
    expect([peeper.power, peeper.toughness]).to eq([2, 1])
  end

  it "adds {U} to cast an enchantment spell" do
    make_mana!
    dread = Card("Growing Dread", owner: p1).tap { p1.hand.add(_1) } # {G}{U}
    p1.add_mana(green: 1)

    p1.cast(card: dread) { _1.pay_mana(blue: 1, green: 1) }
    game.stack.resolve!

    expect(dread.zone).to be_battlefield
  end

  it "adds {U} to unlock a door" do
    room = ResolvePermanent("Meat Locker Drowned Diner", owner: p1, doors: [:right])
    make_mana!
    p1.add_mana(blue: 2)

    p1.unlock_door(permanent: room, door: :left) { _1.pay_mana(generic: { blue: 2 }, blue: 1) }

    expect(room.card).to be_fully_unlocked
  end

  it "adds {U} to turn a permanent face up" do
    bears = Card("Grizzly Bears", owner: p1).tap { p1.library.add(_1) }
    manifested = game.manifest!(bears, controller: p1)
    make_mana!
    p1.add_mana(green: 1)

    p1.turn_face_up(permanent: manifested) { _1.pay_mana(generic: { blue: 1 }, green: 1) }

    expect(manifested).not_to be_face_down
  end

  it "can't be spent on a creature spell" do
    make_mana!
    p1.add_mana(green: 1)
    bears = Card("Grizzly Bears", owner: p1).tap { p1.hand.add(_1) }

    expect { p1.cast(card: bears) { _1.pay_mana(generic: { blue: 1 }, green: 1) } }.to raise_error(StandardError)
  end
end
