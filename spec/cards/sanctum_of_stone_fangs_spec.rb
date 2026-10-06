# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SanctumOfStoneFangs do
  include_context "two player game"

  let!(:sanctum) { ResolvePermanent("Sanctum Of Stone Fangs", owner: p1) }

  def first_main(player)
    game.notify!(Magic::Events::FirstMainPhase.new(active_player: player))
    game.settle!
  end

  it "is a legendary Shrine" do
    expect(sanctum.type?("Shrine")).to eq(true)
  end

  it "drains each opponent for X at the beginning of your first main phase" do
    first_main(p1)

    expect(p2.life).to eq(19)
    expect(p1.life).to eq(21)
  end

  it "counts every Shrine you control" do
    ResolvePermanent("Sanctum Of Tranquil Light", owner: p1)
    first_main(p1)

    expect(p2.life).to eq(18)
    expect(p1.life).to eq(22)
  end

  it "doesn't trigger in an opponent's first main phase" do
    first_main(p2)

    expect(p2.life).to eq(20)
    expect(p1.life).to eq(20)
  end
end
