require 'spec_helper'

RSpec.describe Magic::Player do
  include_context "two player game"

  context "draw" do
    it "draws a card" do
      p1.draw!
      expect(p1.hand.cards.by_name("Forest").count).to eq(1)
    end
  end
end
