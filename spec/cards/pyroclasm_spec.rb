# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Pyroclasm do
  include_context "two player game"

  before { go_to_main_phase! }

  it "deals 2 damage to each creature" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    giant = ResolvePermanent("Colossal Dreadmaw", owner: p2)
    card = Card("Pyroclasm", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: 2)
    p1.cast(card:) { |a| a.pay_mana(generic: { red: 1 }, red: 1) }
    game.stack.resolve!
    game.settle!

    expect(p1.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    expect(giant.damage).to eq(2)
    expect(p2.creatures).to include(giant)
    expect(bears.zone).to be_nil
  end
end
