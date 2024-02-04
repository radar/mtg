require "spec_helper"

RSpec.describe Magic::Cards::TwinbladeAssassins do
  include_context "two player game"

  let!(:permanent) { ResolvePermanent("Twinblade Assassins") }

  context "when a creature hasn't died" do
    it "doesn't trigger" do
      expect(p1).not_to receive(:draw!)
      game.current_turn.end!
    end
  end

  context "when a creature has died on controller's end step" do
    before do
      wood_elves = ResolvePermanent("Wood Elves", owner: p2)
      wood_elves.destroy!
    end

    it "triggers the draw card effect" do
      expect(p1).to receive(:draw!)
      game.current_turn.end!
    end
  end

  context "when a creature has died on other player's end step" do
    before do
      game.next_turn

      wood_elves = ResolvePermanent("Wood Elves", owner: p2)
      wood_elves.destroy!
    end

    it "does not trigger the draw card effect" do
      expect(p1).not_to receive(:draw!)
      game.current_turn.end!
    end
  end
end
