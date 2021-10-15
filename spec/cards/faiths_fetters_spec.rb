require 'spec_helper'

RSpec.describe Magic::Cards::FaithsFetters do
  let(:game) { Magic::Game.new }
  let(:p1) { game.add_player }

  subject { Card("Faith's Fetters", controller: p1) }

  context "with wood elves" do
    let(:wood_elves) { Card("Wood Elves") }

    before do
      game.battlefield.add(wood_elves)
    end

    it "makes the controller gain 4 life" do
      expect { subject.resolve! }.to change { p1.life }.by(4)
    end

    it "enchants the wood elves" do
      subject.resolve!
      game.stack.resolve!
      expect(wood_elves.can_attack?).to eq(false)
      expect(wood_elves.can_block?).to eq(false)
    end

    it "disables activated abilities for permanent"

    it "still allows mana abilities for permanent"

    it "card goes to controller's graveyard when permanent leaves battlefield"
  end
end
