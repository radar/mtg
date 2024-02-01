require "spec_helper"

RSpec.describe Magic::Game do
  include_context "two player game"

  context "take additional turn" do
    it "player 1 has turns 1 and 2" do
      game.take_additional_turn
      expect(game.turns.size).to eq(2)
      expect(game.turns.map(&:number)).to eq([1, 2])

      expect(game.current_turn.number).to eq(1)
      expect(game.current_turn.active_player).to eq(p1)

      game.next_turn

      expect(game.current_turn.number).to eq(2)
      expect(game.current_turn.active_player).to eq(p1)
    end
  end

  context "next_turn" do
    it "player 1 has turns 1 and 2" do
      expect(game.current_turn.number).to eq(1)
      expect(game.current_turn.active_player).to eq(p1)

      game.next_turn

      expect(game.current_turn.number).to eq(2)
      expect(game.current_turn.active_player).to eq(p2)
    end
  end
end
