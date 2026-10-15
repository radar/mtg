# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SneakySnacker do
  include_context "two player game"

  let(:card) { Card("Sneaky Snacker", owner: p1).tap { p1.graveyard.add(_1) } }

  before { go_to_main_phase! }

  def draw!(player, count)
    count.times { player.draw! }
    game.settle!
  end

  it "is a 2/1 flyer" do
    permanent = ResolvePermanent("Sneaky Snacker", owner: p1)

    expect([permanent.power, permanent.toughness]).to eq([2, 1])
    expect(permanent).to have_keyword(Magic::Cards::Keywords::FLYING)
  end

  it "returns tapped when you draw your third card in a turn" do
    card
    drawn = current_turn.events.count { _1.is_a?(Magic::Events::CardDraw) && _1.player == p1 }
    draw!(p1, 3 - drawn)

    expect(card.zone).to be_battlefield
    expect(p1.permanents.find { _1.card == card }).to be_tapped
  end

  it "does not return on the second card drawn" do
    card
    drawn = current_turn.events.count { _1.is_a?(Magic::Events::CardDraw) && _1.player == p1 }
    draw!(p1, 2 - drawn)

    expect(card.zone).to be_graveyard
  end

  it "does not return on the fourth card" do
    card
    drawn = current_turn.events.count { _1.is_a?(Magic::Events::CardDraw) && _1.player == p1 }
    draw!(p1, 2 - drawn)
    p1.graveyard.remove(card)
    p1.hand.add(card)
    draw!(p1, 1)
    p1.hand.remove(card)
    p1.graveyard.add(card)
    draw!(p1, 1)

    expect(card.zone).to be_graveyard
  end

  it "does not return when the opponent draws their third card" do
    card
    draw!(p2, 3)

    expect(card.zone).to be_graveyard
  end

  it "does nothing when it is not in the graveyard" do
    permanent = ResolvePermanent("Sneaky Snacker", owner: p1)
    draw!(p1, 3)

    expect(p1.permanents.count { _1.card == permanent.card }).to eq(1)
  end
end
