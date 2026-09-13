# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VoiceOfMany do
  include_context "two player game"

  context "when the opponent controls fewer creatures than you" do
    it "draws a card" do
      hand_before = p1.hand.count
      ResolvePermanent("Voice of Many", owner: p1)

      expect(p1.hand.count).to eq(hand_before + 1)
    end
  end

  context "when the opponent controls at least as many creatures as you" do
    it "does not draw a card" do
      ResolvePermanent("Grizzly Bears", owner: p2)
      hand_before = p1.hand.count

      ResolvePermanent("Voice of Many", owner: p1)

      expect(p1.hand.count).to eq(hand_before)
    end
  end
end
