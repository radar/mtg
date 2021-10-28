require 'spec_helper'

RSpec.describe Magic::Cards::ChargeThrough do
  include_context "two player game"

  let(:charge_through) { described_class.new(game: game, controller: p1) }

  context "cast effect" do
    it "makes the player draw a card" do
      expect(p1).to receive(:draw!)
      charge_through.cast!
      game.stack.resolve!
      expect(charge_through.zone).to be_graveyard
    end
  end
end
