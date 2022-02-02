require 'spec_helper'

RSpec.describe Magic::Cards::Revitalize do
  include_context "two player game"

  subject { described_class.new(game: game, controller: p1) }

  context "cast" do
    it "adds a life to controller's life total, and draws a single card" do
      subject.cast!
      expect(p1).to receive(:draw!)
      game.stack.resolve!
      expect(p1.life).to eq(23)
    end
  end
end
