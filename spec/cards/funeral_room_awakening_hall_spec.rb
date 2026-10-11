# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FuneralRoomAwakeningHall do
  include_context "two player game"

  before { go_to_main_phase! }

  context "Funeral Room" do
    let!(:room) { ResolvePermanent("Funeral Room Awakening Hall", doors: [:left]) }
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }

    it "drains each opponent when a creature you control dies" do
      bears.destroy!
      game.settle!

      expect(p2.life).to eq(19)
      expect(p1.life).to eq(21)
    end

    it "ignores creatures your opponents control" do
      theirs.destroy!
      game.settle!

      expect(p2.life).to eq(20)
      expect(p1.life).to eq(20)
    end

    it "does nothing while the door is locked" do
      room.lock_door!(:left)
      bears.destroy!
      game.settle!

      expect(p2.life).to eq(20)
    end
  end

  context "Awakening Hall" do
    it "returns all creature cards from your graveyard to the battlefield when unlocked" do
      room = ResolvePermanent("Funeral Room Awakening Hall", doors: [:left])
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      other = ResolvePermanent("Grizzly Bears", owner: p1)
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      [bears, other, theirs].each(&:destroy!)
      game.settle!
      p1.graveyard.add(Card("Sanctum Of Calm Waters", owner: p1))
      life = [p1.life, p2.life]

      p1.add_mana(black: 8)
      p1.unlock_door(permanent: room, door: :right) { |a| a.pay_mana(generic: { black: 6 }, black: 2) }
      game.settle!

      expect(p1.creatures.map(&:name)).to eq(["Grizzly Bears", "Grizzly Bears"])
      expect(p1.graveyard.cards.map(&:name)).to eq(["Sanctum of Calm Waters"])
      expect(p2.creatures).to be_empty
      expect(p2.graveyard.cards.count).to eq(1)
      expect([p1.life, p2.life]).to eq(life)
    end
  end
end
