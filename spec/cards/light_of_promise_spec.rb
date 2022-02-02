require 'spec_helper'

RSpec.describe Magic::Cards::LightOfPromise do
  include_context "two player game"

  subject { Card("Light Of Promise", controller: p1) }

  context "resolution" do
    let(:wood_elves) { Card("Wood Elves", controller: p1) }

    before do
      game.battlefield.add(wood_elves)
    end

    it "enchants the wood elves" do
      subject.resolve!
      game.stack.resolve!
      p1.gain_life(3)
      expect(wood_elves.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(3)
    end
  end
end
