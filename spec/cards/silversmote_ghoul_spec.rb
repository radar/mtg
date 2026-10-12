# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SilversmoteGhoul do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:ghoul) { ResolvePermanent("Silversmote Ghoul", owner: p1) }

  it "is a 3/1 Zombie Vampire" do
    expect([ghoul.power, ghoul.toughness]).to eq([3, 1])
  end

  it "sacrifices itself to draw a card" do
    hand_size = p1.hand.count
    p1.add_mana(black: 2)
    p1.activate_ability(ability: ghoul.activated_abilities.first) { _1.pay_mana(generic: { black: 1 }, black: 1) }
    game.stack.resolve!
    game.settle!

    expect(p1.hand.count).to eq(hand_size + 1)
    expect(ghoul.card.zone).to be_graveyard
  end

  context "in the graveyard" do
    before do
      ghoul.sacrifice!
      game.settle!
    end

    def returned = p1.creatures.by_name("Silversmote Ghoul").first

    it "returns tapped at your end step if you gained 3 or more life this turn" do
      p1.gain_life(3)
      current_turn.end!
      game.settle!

      expect(returned).not_to be_nil
      expect(returned).to be_tapped
    end

    it "stays put if you gained less than 3 life" do
      p1.gain_life(2)
      current_turn.end!
      game.settle!

      expect(returned).to be_nil
    end
  end
end
