require 'spec_helper'

RSpec.describe Magic::Cards::FontOfFertility do
  let(:game) { Magic::Game.new }
  let(:island) { Card("Island") }
  let(:p1) { game.add_player(library: [island]) }
  subject { Card("Font Of Fertility", controller: p1) }

  context "triggered ability" do
    it "searches for a basic land, puts it on the battlefield tapped" do
      expect(subject.activated_abilities.count).to eq(1)
      p1.add_mana(green: 2)
      activation = p1.prepare_to_activate(subject.activated_abilities.first)
      activation.pay(generic: { green: 1 }, green: 1)
      activation.activate!
      game.stack.resolve!
      expect(subject.zone).to be_graveyard
      expect(island.zone).to be_battlefield
      expect(island).to be_tapped
      expect(game.battlefield.cards).to include(island)
    end
  end
end
