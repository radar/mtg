require 'spec_helper'

RSpec.describe Magic::Cards::FaithsFetters do
  let(:game) { Magic::Game.new }
  let(:player) { game.add_player }

  subject { Card("Faith's Fetters") }

  context "with wood elves" do
    let(:wood_elves) { Card("Wood Elves") }

    it "enchants the wood elves" do
      subject.resolve!
      game.stack.resolve!
      expect(wood_elves.can_attack?).to eq(false)
      expect(wood_elves.can_block?).to eq(false)
    end
  end
end
