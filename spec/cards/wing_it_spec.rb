# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WingIt do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:wing_it) { Card("Wing It", owner: p1) }

  before do
    p1.hand.add(wing_it)
    p1.add_mana(white: 2)
    p1.cast(card: wing_it) { |a| a.auto_pay_mana; a.targeting(bears) }
    game.stack.resolve!
    game.settle!
  end

  it "gives the target +2/+2 until end of turn" do
    expect(bears.power).to eq(4)
    expect(bears.toughness).to eq(4)
    current_turn.end!
    current_turn.cleanup!
    game.tick!
    expect(bears.power).to eq(2)
  end

  it "puts a flying counter on it" do
    expect(bears.counters.first).to be_a(Magic::Counters::Flying)
    expect(bears).to have_keyword(:flying)
  end

  it "scries 1" do
    scry = game.choices.last
    expect(scry).to be_a(Magic::Choice::Scry)
    expect(scry.amount).to eq(1)
    game.skip_choice!
  end

  it "can also target an opponent's creature" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    expect(wing_it.target_choices).to include(bears, theirs)
  end
end
