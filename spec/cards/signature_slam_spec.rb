# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SignatureSlam do
  include_context "two player game"

  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:theirs) { ResolvePermanent("Serra Angel", owner: p2) }
  let(:spell) { Card("Signature Slam", owner: p1) }

  def slam(target, victim)
    p1.add_mana(green: 3)
    p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 2 }, green: 1).targeting(target, victim) }
    game.stack.resolve!
    game.settle!
  end

  it "puts a +1/+1 counter on the target creature" do
    slam(mine, theirs)

    expect(mine.power).to eq(3)
  end

  it "has the buffed creature deal damage equal to its power" do
    slam(mine, theirs)

    expect(theirs.damage).to eq(3)
  end

  it "rejects an opponent's creature as the first target" do
    expect { slam(theirs, theirs) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "rejects your own creature as the second target" do
    other = ResolvePermanent("Grizzly Bears", owner: p1)
    expect { slam(mine, other) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "has every other modified creature you control deal damage too" do
    other = ResolvePermanent("Grizzly Bears", owner: p1)
    other.add_counter("+1/+1")
    game.settle!
    unmodified = ResolvePermanent("Grizzly Bears", owner: p1)

    slam(mine, theirs)

    # 3 from the target, 3 from the other modified creature; the unmodified creature does nothing
    expect(theirs.damage).to eq(6)
    expect(unmodified.zone).not_to be_nil
  end
end
