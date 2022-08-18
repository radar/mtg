require 'spec_helper'

RSpec.describe Magic::Card do
  let(:game) { Magic::Game.start! }
  subject { Magic::Cards::Forest.new(game: game) }

  context "destroy!" do
    it "moves the card to the graveyard" do
      subject.discard!
      expect(subject.zone).to be_graveyard
    end
  end
end
