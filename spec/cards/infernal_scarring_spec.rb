# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::InfernalScarring do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def enchant(creature)
    card = Card("Infernal Scarring", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 2)
    p1.cast(card:) { |a| a.pay_mana(generic: { black: 1 }, black: 1).targeting(creature) }
    game.stack.resolve!
    game.settle!
  end

  it "gives the enchanted creature +2/+0" do
    enchant(bears)

    expect([bears.power, bears.toughness]).to eq([4, 2])
  end

  it "draws its controller a card when the enchanted creature dies" do
    enchant(bears)
    hand_size = p1.hand.count
    bears.destroy!
    game.settle!

    expect(p1.hand.count).to eq(hand_size + 1)
  end

  it "draws the creature's controller a card, even when that is an opponent" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    enchant(theirs)
    hand_size = p2.hand.count
    theirs.destroy!
    game.settle!

    expect(p2.hand.count).to eq(hand_size + 1)
  end

  it "doesn't draw when another creature dies" do
    enchant(bears)
    hand_size = p1.hand.count
    ResolvePermanent("Grizzly Bears", owner: p2).destroy!
    game.settle!

    expect(p1.hand.count).to eq(hand_size)
  end
end
