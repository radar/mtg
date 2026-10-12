# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ElvenRaftSteerer do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:steerer) { ResolvePermanent("Elven Raft Steerer", owner: p1) }
  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def play_land
    forest = Card("Forest", owner: p1)
    p1.hand.add(forest)
    p1.play_land(land: forest)
    game.settle!
  end

  it "is a 3/2 Elf Pilot" do
    expect([steerer.power, steerer.toughness]).to eq([3, 2])
    expect(steerer.type?("Elf")).to eq(true)
  end

  it "taps target creature an opponent controls" do
    play_land
    game.resolve_choice!(mode: :tap)
    # A lone legal target is chosen automatically.
    expect(theirs).to be_tapped
    expect(mine).not_to be_tapped
  end

  it "untaps target creature you control" do
    mine.tap!
    play_land
    game.resolve_choice!(mode: :untap)
    expect(game.choices.last.choices).to contain_exactly(steerer, mine)
    game.resolve_choice!(target: mine)
    expect(mine).not_to be_tapped
  end

  it "doesn't trigger when an opponent's land enters" do
    go_to_main_phase_for!(p2)
    forest = Card("Forest", owner: p2)
    p2.hand.add(forest)
    p2.play_land(land: forest)
    game.settle!
    expect(game.choices).to be_empty
  end
end
