# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WildvinePummeler do
  include_context "two player game"
  before { go_to_main_phase! }

  it "has reach and trample" do
    permanent = ResolvePermanent("Wildvine Pummeler", owner: p1)
    expect(permanent.reach?).to eq(true)
    expect(permanent.trample?).to eq(true)
  end

  it "costs {1} less for each color among permanents you control" do
    ResolvePermanent("Alaborn Trooper", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p1)
    card = Card("Wildvine Pummeler", owner: p1)
    p1.hand.add(card)

    # W + G = 2 colors: {6}{G} becomes {4}{G}
    p1.add_mana(green: 5)
    cast_and_resolve(card: card, player: p1) { |a| a.pay_mana(generic: { green: 4 }, green: 1) }

    expect(card.zone).to be_a(Magic::Zones::Battlefield)
  end

  it "costs full price with no colored permanents" do
    card = Card("Wildvine Pummeler", owner: p1)
    p1.hand.add(card)
    expect(Magic::Actions::Cast.new(card: card, player: p1, game: game).mana_cost.cost[:generic]).to eq(6)
  end
end
