# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UnholyAnnexRitualChamber do
  include_context "two player game"

  before { go_to_main_phase! }

  def demons = p1.creatures.select { _1.type?("Demon") }

  def end_step!
    current_turn.end!
    game.settle!
  end

  describe "Ritual Chamber" do
    it "creates a 6/6 black Demon creature token with flying when unlocked" do
      room = ResolvePermanent("Unholy Annex Ritual Chamber", doors: [:left])
      p1.add_mana(black: 5)
      p1.unlock_door(permanent: room, door: :right) { _1.auto_pay }
      game.settle!

      expect(demons.size).to eq(1)
      expect([demons.first.power, demons.first.toughness]).to eq([6, 6])
      expect(demons.first.colors).to eq([:black])
      expect(demons.first).to have_keyword(:flying)
    end
  end

  describe "Unholy Annex" do
    let!(:room) { ResolvePermanent("Unholy Annex Ritual Chamber", doors: [:left]) }

    it "draws a card and costs you 2 life at your end step with no Demon" do
      hand = p1.hand.cards.count
      end_step!

      expect(p1.hand.cards.count).to eq(hand + 1)
      expect(p1.life).to eq(18)
      expect(p2.life).to eq(20)
    end

    it "drains each opponent for 2 if you control a Demon" do
      Magic::Cards::UnholyAnnexRitualChamber::DemonToken.new(game: game, owner: p1).resolve!
      end_step!

      expect(p1.life).to eq(22)
      expect(p2.life).to eq(18)
    end

    it "does nothing at an opponent's end step" do
      game.next_turn
      go_to_main_phase!
      hand = p1.hand.cards.count
      current_turn.end!
      game.settle!

      expect(p1.hand.cards.count).to eq(hand)
      expect(p1.life).to eq(20)
    end
  end
end
