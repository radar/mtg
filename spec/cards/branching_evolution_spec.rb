# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BranchingEvolution do
  include_context "two player game"

  let!(:evolution) { ResolvePermanent("Branching Evolution", owner: p1) }
  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def put_counter(target, type = Magic::Counters::Plus1Plus1)
    mine.trigger_effect(:add_counter, counter_type: type, target: target)
  end

  it "doubles +1/+1 counters put on a creature you control" do
    put_counter(mine)

    game.tick!

    expect(mine.counters.count).to eq(2)
    expect(mine.power).to eq(4)
  end

  it "stacks with a second copy" do
    ResolvePermanent("Branching Evolution", owner: p1)
    put_counter(mine)

    expect(mine.counters.count).to eq(4)
  end

  it "does not double counters on a creature an opponent controls" do
    put_counter(theirs)

    expect(theirs.counters.count).to eq(1)
  end

  it "does not double other kinds of counters" do
    put_counter(mine, Magic::Counters::Stun)

    expect(mine.counters.count).to eq(1)
  end

  it "does not double counters on a noncreature permanent you control" do
    artifact = ResolvePermanent("Sol Ring", owner: p1)
    put_counter(artifact)

    expect(artifact.counters.count).to eq(1)
  end

  it "stops doubling once it leaves the battlefield" do
    evolution.destroy!
    game.settle!
    put_counter(mine)

    expect(mine.counters.count).to eq(1)
  end
end
