# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PursuedWhale do
  include_context "two player game"

  let!(:whale) { ResolvePermanent("Pursued Whale", owner: p1) }

  def pirate = p2.creatures.by_name("Pirate").first

  it "is an 8/8 Whale" do
    expect([whale.power, whale.toughness]).to eq([8, 8])
  end

  describe "when it enters" do
    before { game.settle! }

    it "gives each opponent a 1/1 red Pirate that can't block" do
      expect([pirate.power, pirate.toughness]).to eq([1, 1])
      expect(pirate.colors).to eq([:red])
      expect(pirate.can_block?(ResolvePermanent("Grizzly Bears", owner: p1))).to eq(false)
    end

    it "makes the opponent's creatures attack each combat if able" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)

      expect(bears.must_attack?).to eq(true)
      expect(pirate.must_attack?).to eq(true)
    end

    it "doesn't force your own creatures to attack" do
      mine = ResolvePermanent("Grizzly Bears", owner: p1)

      expect(mine.must_attack?).to eq(false)
    end
  end

  describe "spells your opponents cast that target it" do
    before { go_to_main_phase_for!(p2) }

    def cast_bolt(player, target, mana)
      bolt = Card("Lightning Bolt", owner: player)
      player.hand.add(bolt)
      player.add_mana(red: mana)
      player.cast(card: bolt) do |a|
        a.pay_mana(red: 1)
        a.targeting(target)
        a.pay_mana(generic: { red: 3 }) if mana > 1
      end
    end

    it "cost {3} more" do
      expect { cast_bolt(p2, whale, 4) }.not_to raise_error
    end

    it "can't be cast without paying the extra {3}" do
      expect { cast_bolt(p2, whale, 1) }.to raise_error(StandardError)
    end

    it "cost nothing extra when they target something else" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)

      expect { cast_bolt(p2, bears, 1) }.not_to raise_error
    end

    it "cost nothing extra for you" do
      go_to_main_phase_for!(p1)

      expect { cast_bolt(p1, whale, 1) }.not_to raise_error
    end
  end
end
