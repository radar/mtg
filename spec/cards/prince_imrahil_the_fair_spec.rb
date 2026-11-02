# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PrinceImrahilTheFair do
  include_context "two player game"

  let!(:imrahil) { ResolvePermanent("Prince Imrahil The Fair", owner: p1) }

  # Reaching the main phase makes p1's draw-step draw: their first card of the turn.
  before { go_to_main_phase! }

  def soldiers(player) = player.creatures.select { _1.token? && _1.type?("Soldier") }

  it "is a legendary 2/2 Human Noble" do
    card = Card("Prince Imrahil The Fair")
    expect(card).to be_legendary
    expect([card.base_power, card.base_toughness]).to eq([2, 2])
    expect(card.type?("Human")).to be(true)
    expect(card.type?("Noble")).to be(true)
  end

  it "does not trigger on the first draw of the turn" do
    game.settle!
    expect(soldiers(p1)).to be_empty
    expect(game.choices).to be_empty
  end

  it "creates a 1/1 white Human Soldier token on the second draw" do
    p1.draw!
    game.settle!
    expect(soldiers(p1).count).to eq(1)
    token = soldiers(p1).first
    expect(token.type?("Human")).to be(true)
    expect(token.colors).to include(:white)
    expect([token.power, token.toughness]).to eq([1, 1])
  end

  it "does not trigger again on the third draw" do
    2.times { p1.draw! }
    game.settle!
    expect(soldiers(p1).count).to eq(1)
  end

  it "triggers again on the second draw of a later turn" do
    p1.draw!
    game.settle!
    2.times { game.next_turn }
    go_to_main_phase!
    game.settle!
    expect(soldiers(p1).count).to eq(1)
    p1.draw!
    game.settle!
    expect(soldiers(p1).count).to eq(2)
  end

  it "does not trigger when the opponent draws their second card" do
    2.times { p2.draw! }
    game.settle!
    expect(soldiers(p1)).to be_empty
    expect(soldiers(p2)).to be_empty
    expect(game.choices).to be_empty
  end
end
