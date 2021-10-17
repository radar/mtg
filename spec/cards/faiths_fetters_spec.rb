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
  end

  context "with llanowar elves" do
    let(:llanowar_elves) { Card("Llanowar Elves") }

    before do
      game.battlefield.add(llanowar_elves)
    end

    it "enchants the llanowar elves" do
      subject.resolve!
      game.stack.resolve!
      expect(llanowar_elves.can_attack?).to eq(false)
      expect(llanowar_elves.can_block?).to eq(false)
      expect(llanowar_elves.can_activate_ability?(llanowar_elves.activated_abilities.first)).to eq(true)
    end
  end

  context "with hellkite punisher" do
    let(:hellkite_punisher) { Card("Hellkite Punisher") }

    before do
      game.battlefield.add(hellkite_punisher)
    end

    it "enchants the llanowar elves" do
      subject.resolve!
      game.stack.resolve!
      expect(hellkite_punisher.can_attack?).to eq(false)
      expect(hellkite_punisher.can_block?).to eq(false)
      expect(hellkite_punisher.can_activate_ability?(hellkite_punisher.activated_abilities.first)).to eq(false)
    end
  end
end
