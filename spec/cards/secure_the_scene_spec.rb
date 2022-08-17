require 'spec_helper'

RSpec.describe Magic::Cards::SecureTheScene do
  include_context "two player game"

  subject(:secure_the_scene) { described_class.new(game: game, controller: p1) }

  context "with a creature" do
    let(:wood_elves) { Card("Wood Elves", game: game, controller: p2) }

    before do
      game.battlefield.add(wood_elves)
    end

    it "exiles the wood elves, replaces them with a 1/1 White Soldier" do
      p1.add_mana(white: 5)
      action = Magic::Actions::Cast.new(player: p1, card: secure_the_scene)
      action.pay_mana(generic: { white: 4 }, white: 1)
      action.targeting(wood_elves)
      game.take_action(action)
      game.tick!

      expect(wood_elves.zone).to be_exile
      soldier = game.battlefield.creatures.controlled_by(p2).first
      expect(soldier.name).to eq("Soldier")
      expect(soldier.power).to eq(1)
      expect(soldier.toughness).to eq(1)
      expect(soldier.colors).to eq([:white])
    end
  end

end
