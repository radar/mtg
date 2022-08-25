require 'spec_helper'

RSpec.describe Magic::Card do
  include_context "two player game"
  subject { Magic::Cards::Forest.new(game: game) }

  before do
    p1.library.add(subject)
  end

  context "destroy!" do
    it "moves the card to the graveyard" do
      subject.discard!
      expect(subject.zone).to be_graveyard
    end
  end
end
