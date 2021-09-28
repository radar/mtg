require 'spec_helper'

RSpec.describe Magic::Cards::ProfaneMemento do
  let(:p1) { Magic::Player.new }
  subject { Card("Profane Memento", controller: p1) }

  context "receive notification" do
    context "when creature enters controller's graveyard" do
      it "does not gain life"
    end

    context "when create enters opponent's graveyard" do
      it "gains life"
    end
  end
end
