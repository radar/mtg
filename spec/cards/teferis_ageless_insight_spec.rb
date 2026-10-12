# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TeferisAgelessInsight do
  include_context "two player game"

  let!(:insight) { ResolvePermanent("Teferi's Ageless Insight", owner: p1) }

  # A draw caused by an effect (not the turn's own draw), here with Teferi's Ageless Insight as its source.
  def draw_effect(player, amount = 1)
    insight.trigger_effect(:draw_cards, player:, number_to_draw: amount)
    game.settle!
  end

  it "is a legendary Enchantment" do
    expect(insight.types).to include(Magic::Types::Super::Legendary, Magic::Types::Enchantment)
  end

  it "makes a draw outside the draw step draw two cards" do
    hand_size = p1.hand.count
    draw_effect(p1)

    expect(p1.hand.count).to eq(hand_size + 2)
  end

  it "doubles a multi-card draw" do
    hand_size = p1.hand.count
    draw_effect(p1, 2)

    expect(p1.hand.count).to eq(hand_size + 4)
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
