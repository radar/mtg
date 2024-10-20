require 'spec_helper'

RSpec.describe Magic::Cards::PhyrexianArena do
  include_context "two player game"

  subject! { ResolvePermanent("Phyrexian Arena", owner: p1) }

  context "at the beginning of your upkeep" do
    it "loses a life, draws a card" do
      turn_1 = game.current_turn

      turn_1.untap!

      expect(p1.life).to eq(20)
      turn_1 = game.current_turn
      expect(p1).to receive(:draw!)
      turn_1.upkeep!
      expect(p1.life).to eq(19)
    end
  end
end
