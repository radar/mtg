require 'spec_helper'

RSpec.describe Magic::Cards::ChargeThrough do
  let(:game) { Magic::Game.new }
  let(:p1) { Magic::Player.new(game: game) }
  let(:charge_through) { described_class.new(controller: p1) }

  before do
    charge_through.draw!
  end

  context "cast effect" do
    it "makes the player draw a card" do
      expect(p1).to receive(:draw!)
      charge_through.cast!
      expect(charge_through.zone).to be_graveyard
    end
  end
end
