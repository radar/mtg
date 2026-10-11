# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OvergrownZealot do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:zealot) { ResolvePermanent("Overgrown Zealot", owner: p1) }

  def manifest(name)
    card = Card(name, owner: p1).tap { p1.library.add(_1) }
    game.manifest!(card, controller: p1)
  end

  it "is a 0/4 Elf Druid" do
    expect([zealot.power, zealot.toughness]).to eq([0, 4])
  end

  it "taps for one mana of any color" do
    p1.activate_ability(ability: zealot.activated_abilities.first) { _1.choose(:red) }

    expect(p1.mana_pool[:red]).to eq(1)
    expect(zealot).to be_tapped
  end

  describe "the second ability" do
    def make_two!(color)
      p1.activate_ability(ability: zealot.activated_abilities.last) { _1.choose(color) }
    end

    it "adds two mana of one color that can turn a permanent face up" do
      bears = manifest("Grizzly Bears") # {1}{G}
      make_two!(:green)
      p1.turn_face_up(permanent: bears) { _1.pay_mana(generic: { green: 1 }, green: 1) }

      expect(bears).not_to be_face_down
    end

    it "can't be spent on spells" do
      make_two!(:green)
      bears = Card("Grizzly Bears", owner: p1).tap { p1.hand.add(_1) }

      expect { p1.cast(card: bears) { _1.pay_mana(generic: { green: 1 }, green: 1) } }.to raise_error(StandardError)
    end

    it "can't be spent to unlock a door" do
      room = ResolvePermanent("Meat Locker Drowned Diner", owner: p1, doors: [:right])
      make_two!(:blue)
      p1.add_mana(blue: 1)

      expect { p1.unlock_door(permanent: room, door: :left) { _1.pay_mana(generic: { blue: 2 }, blue: 1) } }.to raise_error(StandardError)
    end
  end
end
