# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GundabadOpportunist do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:top) { Card("Lake Town Lookout", owner: p1) }

  before { p1.library.add(top) }

  it "is a 4/2 Goblin Rogue" do
    opportunist = ResolvePermanent("Gundabad Opportunist", owner: p1)
    expect(opportunist.power).to eq(4)
    expect(opportunist.toughness).to eq(2)
  end

  it "exiles the top card of your library and lets you play it" do
    ResolvePermanent("Gundabad Opportunist", owner: p1)
    expect(top.zone).to be_exile
    expect(game.play_permissions.permits?(top, p1)).to eq(true)
    p1.add_mana(white: 1)
    p1.cast(card: top) { |a| a.pay_mana(white: 1) }
    game.stack.resolve!
    expect(p1.permanents.map(&:name)).to include("Lake-town Lookout")
  end

  it "lets you play it until the end of your next turn but not after" do
    ResolvePermanent("Gundabad Opportunist", owner: p1)
    game.next_turn
    expect(game.play_permissions.permits?(top, p1)).to eq(true)
    game.next_turn
    expect(game.play_permissions.permits?(top, p1)).to eq(true)
    game.next_turn
    game.next_turn
    expect(game.play_permissions.permits?(top, p1)).to eq(false)
  end
end
