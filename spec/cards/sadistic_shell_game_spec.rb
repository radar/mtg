# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SadisticShellGame do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:spell) { Card("Sadistic Shell Game", owner: p1).tap { p1.hand.add(_1) } }
  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:small) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:big) { ResolvePermanent("Shroudstomper", owner: p2) }
  let!(:third) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def cast!
    p1.add_mana(black: 5)
    p1.cast(card: spell) { _1.pay_mana(generic: { black: 4 }, black: 1) }
    game.stack.resolve!
    game.settle!
    game.skip_choice! while game.choices.any? && !game.choices.last.is_a?(described_class::PickChoice)
  end

  it "asks the opponent first, then you, and each picks a creature you don't control" do
    cast!
    first = game.choices.last
    expect(first.chooser).to eq(p2)
    expect(first.choices).to contain_exactly(small, big, third)
    game.resolve_choice!(target: small)

    second = game.choices.last
    expect(second.chooser).to eq(p1)
    game.resolve_choice!(target: big)
    game.settle!

    expect(small.zone).to be_nil
    expect(big.zone).to be_nil
    expect(third.zone).to be_battlefield
    expect(mine.zone).to be_battlefield
  end

  it "destroys one creature when both players choose the same one" do
    cast!
    game.resolve_choice!(target: big)
    game.resolve_choice!(target: big)
    game.settle!

    expect(big.zone).to be_nil
    expect([small.zone, third.zone]).to all(be_battlefield)
  end

  it "doesn't let anyone choose your own creature" do
    cast!

    expect(game.choices.last.choices).not_to include(mine)
  end

  it "does nothing when you control the only creatures" do
    [small, big, third].each(&:destroy!)
    game.settle!
    p1.add_mana(black: 5)
    p1.cast(card: spell) { _1.pay_mana(generic: { black: 4 }, black: 1) }
    game.stack.resolve!
    game.settle!

    expect(mine.zone).to be_battlefield
  end
end
