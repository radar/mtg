# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DecreeOfJustice do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:spell) { Card("Decree Of Justice", owner: p1).tap { p1.hand.add(_1) } }

  def angels = p1.creatures.select { _1.name == "Angel" }

  def soldiers = p1.creatures.select { _1.name == "Soldier" }

  it "creates X 4/4 flying Angels" do
    p1.add_mana(white: 8)
    p1.cast(card: spell, value_for_x: 2) { _1.pay_mana(x: { white: 4 }, generic: { white: 2 }, white: 2) }
    game.stack.resolve!
    game.settle!

    expect(angels.size).to eq(2)
    expect(angels.first.power).to eq(4)
    expect(angels.first.flying?).to eq(true)
  end

  describe "cycling {2}{W}" do
    before do
      p1.add_mana(white: 5)
      spell
      @hand = p1.hand.cards.count
      p1.cycle(card: spell) { _1.pay_mana(generic: { white: 2 }, white: 1) }
      game.settle!
    end

    it "draws a card, then lets you pay X for X Soldiers" do
      game.resolve_choice!(x: 2)

      expect(p1.hand.cards.count).to eq(@hand)
      expect(soldiers.size).to eq(2)
      expect(p1.mana_pool.values.sum).to eq(0)
    end

    it "makes no Soldiers if declined" do
      game.skip_choice!

      expect(soldiers).to be_empty
    end
  end
end
