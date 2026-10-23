# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MeteoricMace do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:mace) { ResolvePermanent("Meteoric Mace", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "gives equipped creature +4/+0 and trample" do
    mace.attach_to!(bears)
    game.tick!

    expect(bears.power).to eq(6)
    expect(bears.toughness).to eq(2)
    expect(bears.keywords).to include(Magic::Cards::Keywords::TRAMPLE)
  end

  it "cascades into a cheaper spell when cast" do
    cheap = Card("Grizzly Bears", owner: p1)
    p1.library.add(cheap)
    card = Card("Meteoric Mace", owner: p1).tap { p1.hand.add(_1) }

    p1.add_mana(red: 6)
    p1.cast(card: card) { |action| action.pay_mana(red: 2, generic: { red: 4 }) }
    game.settle!

    expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
  end
end
