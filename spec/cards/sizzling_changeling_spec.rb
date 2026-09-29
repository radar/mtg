# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SizzlingChangeling do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:changeling) { ResolvePermanent("Sizzling Changeling", owner: p1) }

  it "is a 3/2 changeling" do
    expect([changeling.power, changeling.toughness]).to eq([3, 2])
    expect(changeling.type?("Goblin")).to be(true)
  end

  it "exiles the top card of your library when it dies, and you may play it until the end of your next turn" do
    top = p1.library.first
    changeling.destroy!
    game.settle!

    expect(top.zone).to be_exile
    expect(game.play_permissions.permits?(top, p1)).to be(true)
    expect(game.play_permissions.permits?(top, p2)).to be(false)
  end

  it "lets you play an exiled land" do
    land = Card("Forest", owner: p1)
    p1.library.add(land)
    changeling.destroy!
    game.settle!
    p1.play_land(land:)

    expect(p1.lands.map(&:name)).to include("Forest")
  end

  it "the permission lasts through your next turn, then ends" do
    top = p1.library.first
    changeling.destroy!
    game.settle!
    game.next_turn # the opponent's turn
    go_to_main_phase!
    expect(game.play_permissions.permits?(top, p1)).to be(true)

    game.next_turn # your next turn
    go_to_main_phase!
    expect(game.play_permissions.permits?(top, p1)).to be(true)

    game.next_turn
    go_to_main_phase!
    expect(game.play_permissions.permits?(top, p1)).to be(false)
  end

  it "does nothing with an empty library" do
    p1.library.to_a.each { p1.library.remove(_1) }
    changeling.destroy!
    game.settle!

    expect(changeling.card.zone).to be_graveyard
  end
end
