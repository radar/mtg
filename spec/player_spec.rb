require 'spec_helper'

RSpec.describe Magic::Player do
  include_context "two player game"


  context "draw" do
    def p1_library
      [
        Card("Forest"),
        Card("Forest"),
        Card("Forest"),
        Card("Forest"),
        Card("Forest"),
        Card("Forest"),
        Card("Forest"),
        Card("Mountain"),
      ]
    end

    it "draws a card" do
      # Initial game draw
      expect(p1.hand.cards.by_name("Forest").count).to eq(7)
      p1.draw!
      expect(p1.hand.cards.by_name("Mountain").count).to eq(1)
    end
  end
end
