# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GwaihirTheWindlord do
  include_context "two player game"

  def draws_this_turn(player = p1)
    game.current_turn.events.count { _1.is_a?(Magic::Events::CardDraw) && _1.player == player }
  end

  def draw_until(count)
    p1.draw! while draws_this_turn < count
    game.settle!
  end

  def cast_gwaihir(card, green)
    p1.add_mana(white: 1, blue: 1, green: green)
    p1.cast(card: card) { |a| a.pay_mana(white: 1, blue: 1, generic: { green: green }) }
    game.stack.resolve!
    game.tick!
  end

  def gwaihirs = p1.creatures.select { _1.name == "Gwaihir the Windlord" }

  describe "stats and keywords" do
    let!(:gwaihir) { ResolvePermanent("Gwaihir The Windlord", owner: p1) }

    it "is a 4/4 legendary Bird Noble with flying and vigilance" do
      expect([gwaihir.power, gwaihir.toughness]).to eq([4, 4])
      expect(gwaihir.type?("Bird")).to be(true)
      expect(gwaihir.type?("Noble")).to be(true)
      expect(gwaihir).to have_keyword(:flying)
      expect(gwaihir).to have_keyword(:vigilance)
    end

    it "gives other Birds you control vigilance" do
      hawk = ResolvePermanent("Healers Hawk", owner: p1)
      game.tick!

      expect(hawk).to have_keyword(:vigilance)
    end

    it "does not give non-Birds vigilance" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      game.tick!

      expect(bears).not_to have_keyword(:vigilance)
    end

    it "does not give an opponent's Birds vigilance" do
      hawk = ResolvePermanent("Healers Hawk", owner: p2)
      game.tick!

      expect(hawk).not_to have_keyword(:vigilance)
    end
  end

  describe "cost reduction" do
    before { go_to_main_phase! }

    let(:card) { Card("Gwaihir The Windlord", owner: p1).tap { p1.hand.add(_1) } }

    it "costs the full {4}{W}{U} with fewer than two cards drawn this turn" do
      expect(draws_this_turn).to be < 2
      cast_gwaihir(card, 4)

      expect(gwaihirs.count).to eq(1)
      expect(p1.mana_pool[:green]).to eq(0)
    end

    it "cannot be cast for the reduced cost with fewer than two draws" do
      expect(draws_this_turn).to be < 2

      expect { cast_gwaihir(card, 2) }.to raise_error(Magic::Costs::Mana::CannotPay)
      expect(gwaihirs).to be_empty
    end

    it "costs {2} less once you have drawn two or more cards this turn" do
      draw_until(2)
      cast_gwaihir(card, 2)

      expect(gwaihirs.count).to eq(1)
      expect(p1.mana_pool[:green]).to eq(0)
    end

    it "ignores the opponent's draws" do
      draw_until(1)
      p2.draw!
      p2.draw!
      game.settle!
      expect(draws_this_turn).to eq(1)

      expect { cast_gwaihir(card, 2) }.to raise_error(Magic::Costs::Mana::CannotPay)
      expect(gwaihirs).to be_empty
    end
  end
end
