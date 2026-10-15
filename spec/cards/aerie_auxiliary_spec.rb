# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AerieAuxiliary do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:elves) { ResolvePermanent("Wood Elves", owner: p1) }
  let!(:enemy) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def enter_auxiliary
    auxiliary = ResolvePermanent("Aerie Auxiliary", owner: p1)
    game.settle!
    auxiliary
  end

  it "is a 3/3 Bird Soldier with flying" do
    auxiliary = ResolvePermanent("Aerie Auxiliary", owner: p1, settle: false)

    expect([auxiliary.power, auxiliary.toughness]).to eq([3, 3])
    expect(auxiliary).to be_flying
    expect(auxiliary.type?("Bird")).to eq(true)
    expect(auxiliary.type?("Soldier")).to eq(true)
  end

  it "puts a +1/+1 counter on each of up to two other target creatures" do
    auxiliary = enter_auxiliary
    game.resolve_choice!(targets: [bears, enemy])
    game.tick!

    expect(bears.counters.count).to eq(1)
    expect(enemy.counters.count).to eq(1)
    expect(elves.counters.count).to eq(0)
    expect(auxiliary.counters.count).to eq(0)
  end

  it "may choose just one creature" do
    enter_auxiliary
    game.resolve_choice!(targets: [elves])

    expect(elves.counters.count).to eq(1)
    expect(bears.counters.count).to eq(0)
  end

  it "may choose none" do
    enter_auxiliary
    game.skip_choice!

    expect((p1.creatures + p2.creatures).sum { _1.counters.count }).to eq(0)
  end

  it "rejects a third target" do
    enter_auxiliary

    expect { game.resolve_choice!(targets: [bears, elves, enemy]) }.to raise_error(ArgumentError)
    expect((p1.creatures + p2.creatures).sum { _1.counters.count }).to eq(0)
  end

  it "does not offer itself" do
    auxiliary = enter_auxiliary
    choices = game.choices.first.choices.to_a

    expect(choices).to contain_exactly(bears, elves, enemy)
    expect(choices).not_to include(auxiliary)
  end

  it "does not offer a hexproof creature of the opponent" do
    big_bear = ResolvePermanent("Gigantic Big Bear", owner: p2)
    enter_auxiliary

    expect(game.choices.first.choices.to_a).not_to include(big_bear)
  end

  it "does nothing when there are no other creatures" do
    [bears, elves, enemy].each(&:destroy!)
    game.settle!
    enter_auxiliary

    expect(game.choices).to be_empty
  end
end
