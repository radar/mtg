require 'spec_helper'

RSpec.describe Magic::Card do
  subject { Magic::Cards::Forest.new }

  context "destroy!" do
    it "moves the card to the graveyard" do
      subject.cast!
      subject.destroy!
      expect(subject.zone).to be_graveyard
    end
  end
end
