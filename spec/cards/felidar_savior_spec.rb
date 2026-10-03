# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FelidarSavior do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:elves) { ResolvePermanent("Wood Elves", owner: p1) }
  let!(:third) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:enemy) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def enter_savior
    savior = ResolvePermanent("Felidar Savior", owner: p1)
    game.settle!
    savior
  end

  it "is a 2/3 lifelink Cat Beast" do
    savior = ResolvePermanent("Felidar Savior", owner: p1, settle: false)

    expect([savior.power, savior.toughness]).to eq([2, 3])
    expect(savior).to be_lifelink
  end

  it "puts a +1/+1 counter on each of up to two other creatures you control" do
    savior = enter_savior
    game.resolve_choice!(targets: [bears, elves])
    game.tick!

    expect(bears.counters.count).to eq(1)
    expect(elves.counters.count).to eq(1)
    expect(third.counters.count).to eq(0)
    expect(savior.counters.count).to eq(0)
  end

  it "may choose just one creature" do
    enter_savior
    game.resolve_choice!(targets: [bears])

    expect(bears.counters.count).to eq(1)
    expect(elves.counters.count).to eq(0)
  end

  it "may choose none" do
    enter_savior
    game.skip_choice!

    expect(p1.creatures.sum { _1.counters.count }).to eq(0)
  end

  it "does not offer itself or the opponent's creatures" do
    savior = enter_savior
    choices = game.choices.first.choices.to_a

    expect(choices).to contain_exactly(bears, elves, third)
    expect(choices).not_to include(savior, enemy)
  end

  it "does nothing when you control no other creatures" do
    [bears, elves, third].each(&:destroy!)
    game.settle!
    enter_savior

    expect(game.choices).to be_empty
  end
end
