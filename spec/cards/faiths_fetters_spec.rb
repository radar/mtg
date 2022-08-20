require 'spec_helper'

RSpec.describe Magic::Cards::FaithsFetters do
  include_context "two player game"

  subject { Card("Faith's Fetters", controller: p1) }

  def cast_faiths_fetters(target)
    p1.add_mana(white: 4)
    action = cast_action(player: p1, card: subject)
      .pay_mana(white: 1, generic: { white: 3 })
      .targeting(target)
    game.take_action(action)
    game.stack.resolve!
  end

  context "with wood elves" do
    let!(:wood_elves) { ResolvePermanent("Wood Elves", controller: p2) }

    it "makes the controller gain 4 life" do
      expect { cast_faiths_fetters(wood_elves) }.to change { p1.life }.by(4)
    end

    it "enchants the wood elves" do
      cast_faiths_fetters(wood_elves)
      expect(wood_elves.can_attack?).to eq(false)
      expect(wood_elves.can_block?).to eq(false)
    end
  end

  context "with llanowar elves" do
    let!(:llanowar_elves) { ResolvePermanent("Llanowar Elves", controller: p2) }
    let(:mana_ability) { llanowar_elves.activated_abilities.first }

    it "enchants the llanowar elves" do
      cast_faiths_fetters(llanowar_elves)
      expect(llanowar_elves.can_attack?).to eq(false)
      expect(llanowar_elves.can_block?).to eq(false)
      expect(llanowar_elves.can_activate_ability?(mana_ability)).to eq(true)
    end
  end

  context "with hellkite punisher" do
    let!(:hellkite_punisher) { ResolvePermanent("Hellkite Punisher", controller: p2) }
    let(:activated_ability) { hellkite_punisher.activated_abilities.first }

    it "enchants the hellkite punisher" do
      cast_faiths_fetters(hellkite_punisher)
      expect(hellkite_punisher.can_attack?).to eq(false)
      expect(hellkite_punisher.can_block?).to eq(false)
      expect(hellkite_punisher.can_activate_ability?(activated_ability)).to eq(false)
    end
  end
end
