# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AlchemistsGift do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def cast(mode)
    card = Card("Alchemist's Gift", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 1)
    p1.cast(card:) { |a| a.pay_mana(black: 1).targeting(bears) }
    game.stack.resolve!
    game.settle!
    game.resolve_choice!(mode:)
    game.tick!
  end

  it "gives +1/+1 and your choice of deathtouch" do
    cast(:deathtouch)

    expect([bears.power, bears.toughness]).to eq([3, 3])
    expect(bears).to be_deathtouch
    expect(bears).not_to be_lifelink
  end

  it "gives +1/+1 and your choice of lifelink" do
    cast(:lifelink)

    expect([bears.power, bears.toughness]).to eq([3, 3])
    expect(bears).to be_lifelink
    expect(bears).not_to be_deathtouch
  end

  it "wears off at end of turn" do
    cast(:lifelink)
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([2, 2])
    expect(bears).not_to be_lifelink
  end
end
