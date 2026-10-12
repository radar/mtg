# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SpikedCorridorTorturePit do
  include_context "two player game"

  def devils = p1.creatures.select { _1.name == "Devil" }

  describe "Spiked Corridor" do
    let(:room) { ResolvePermanent("Spiked Corridor Torture Pit", doors: [:right]) }

    before do
      go_to_main_phase!
      p1.add_mana(red: 4)
      p1.unlock_door(permanent: room, door: :left) { _1.auto_pay }
      game.settle!
    end

    it "creates three 1/1 red Devils when unlocked" do

      expect(devils.size).to eq(3)
      expect(devils.map { [_1.power, _1.toughness] }).to all(eq([1, 1]))
    end

    it "makes a Devil deal 1 damage to any target when it dies" do
      devils.first.destroy!
      game.settle!
      game.resolve_choice!(target: p2)
      game.settle!

      # The room is fully unlocked here, so Torture Pit adds 2 to the 1 damage.
      expect(p2.life).to eq(17)
    end
  end

  describe "Torture Pit" do
    before { ResolvePermanent("Spiked Corridor Torture Pit", doors: [:right]) }

    it "adds 2 to noncombat damage a source you control deals to an opponent" do
      bolt = Card("Lightning Bolt", owner: p1).tap { p1.hand.add(_1) }
      go_to_main_phase!
      p1.add_mana(red: 1)
      p1.cast(card: bolt) { _1.pay_mana(red: 1).targeting(p2) }
      game.stack.resolve!

      expect(p2.life).to eq(15)
    end

    it "doesn't change damage to you or to creatures" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      bolt = Card("Lightning Bolt", owner: p1).tap { p1.hand.add(_1) }
      go_to_main_phase!
      p1.add_mana(red: 1)
      p1.cast(card: bolt) { _1.pay_mana(red: 1).targeting(bears) }
      game.stack.resolve!

      expect(bears.damage).to eq(3)
      expect(p2.life).to eq(20)
    end

    it "doesn't change damage an opponent's source deals" do
      go_to_main_phase_for!(p2)
      bolt = Card("Lightning Bolt", owner: p2).tap { p2.hand.add(_1) }
      p2.add_mana(red: 1)
      p2.cast(card: bolt) { _1.pay_mana(red: 1).targeting(p1) }
      game.stack.resolve!

      expect(p1.life).to eq(17)
    end
  end
end
