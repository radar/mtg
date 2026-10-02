# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SeismicRupture do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:flyer) do
    ResolvePermanent("Grizzly Bears", owner: p2).tap do |permanent|
      permanent.grant_keyword(Magic::Cards::Keywords::FLYING)
      game.tick!
    end
  end

  before { go_to_main_phase! }

  it "deals 2 damage to each creature without flying" do
    p1.add_mana(red: 3)
    p1.cast(card: Card("Seismic Rupture", owner: p1, game:)) { |a| a.pay_mana(generic: { red: 2 }, red: 1) }
    game.stack.resolve!
    game.tick!

    expect(bears).to be_dead
    expect(flyer).not_to be_dead
    expect(flyer.damage).to eq(0)
  end
end
