require 'spec_helper'

RSpec.describe Magic::Cards::LightOfPromise do
  include_context "two player game"

  subject { Card("Light Of Promise") }

  context "resolution" do
    let(:wood_elves) { ResolvePermanent("Wood Elves", controller: p1) }

    it "enchants the wood elves" do
      p1.add_mana(white: 3)
      action = cast_action(player: p1, card: subject)
        .pay_mana(white: 1, generic: { white: 2 })
        .targeting(wood_elves)
      game.take_action(action)
      game.stack.resolve!
      p1.gain_life(3)
      expect(wood_elves.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(3)
    end
  end
end
