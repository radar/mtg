# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BardKingOfDale do
  include_context "two player game"

  let!(:bard) { ResolvePermanent("Bard, King Of Dale", owner: p1) }

  # A draw caused by an effect (not the turn's own draw), with Bard as its source.
  def draw_effect(player, amount = 1)
    bard.trigger_effect(:draw_cards, player:, number_to_draw: amount)
    game.settle!
  end

  def angels(player) = game.battlefield.controlled_by(player).creatures.by_name("Angel").count

  it "is a 3/5 with reach and vigilance" do
    expect([bard.power, bard.toughness]).to eq([3, 5])
    expect(bard).to have_keyword(:reach)
    expect(bard).to have_keyword(:vigilance)
  end

  describe "draw replacement" do
    it "makes a draw outside the draw step draw two cards" do
      hand_size = p1.hand.count
      draw_effect(p1)

      expect(p1.hand.count).to eq(hand_size + 2)
    end

    it "leaves the first card of your draw step alone" do
      hand_size = p1.hand.count
      go_to_main_phase!

      expect(p1.hand.count).to eq(hand_size + 1)
    end

    it "doesn't affect an opponent's draws" do
      hand_size = p2.hand.count
      draw_effect(p2)

      expect(p2.hand.count).to eq(hand_size + 1)
    end
  end

  describe "token replacement" do
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

    def cast_ascension(player, target)
      player.add_mana(white: 2)
      player.cast(card: Card("Angelic Ascension", owner: player)) do
        _1.targeting(target)
        _1.auto_pay_mana
      end
      game.stack.resolve!
    end

    it "creates twice as many tokens under your control" do
      cast_ascension(p1, wood_elves)

      expect(angels(p1)).to eq(2)
    end

    it "doesn't double tokens an opponent creates" do
      opponent_elves = ResolvePermanent("Wood Elves", owner: p2)
      cast_ascension(p2, opponent_elves)

      expect(angels(p2)).to eq(1)
    end
  end
end
