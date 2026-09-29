# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BitterbloomBearer do
  include_context "two player game"

  let!(:bearer) { ResolvePermanent("Bitterbloom Bearer", owner: p1) }

  def upkeep_for(player)
    game.notify!(Magic::Events::BeginningOfUpkeep.new(player:))
    game.settle!
  end

  it "is a 1/1 flash flyer" do
    expect([bearer.power, bearer.toughness]).to eq([1, 1])
    expect(bearer).to be_flying
    expect(bearer.card.flash?).to be(true)
  end

  it "can be cast at instant speed" do
    card = Card("Bitterbloom Bearer", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 2)
    p1.cast(card:) { _1.pay_mana(black: 2) }
    game.stack.resolve!

    expect(p1.creatures.count { _1.name == "Bitterbloom Bearer" }).to eq(2)
  end

  it "makes you lose 1 life and create a 1/1 blue and black Faerie with flying at your upkeep" do
    upkeep_for(p1)
    faerie = p1.creatures.find { _1.name == "Faerie" }

    expect(p1.life).to eq(19)
    expect([faerie.power, faerie.toughness, faerie.colors]).to eq([1, 1, [:blue, :black]]).or eq([1, 1, %i[black blue]])
    expect(faerie).to be_flying
  end

  it "does nothing at the opponent's upkeep" do
    upkeep_for(p2)

    expect(p1.life).to eq(20)
    expect(p1.creatures.map(&:name)).to eq(["Bitterbloom Bearer"])
  end
end
