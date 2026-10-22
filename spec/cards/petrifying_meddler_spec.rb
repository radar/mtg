# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PetrifyingMeddler do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:meddler) { Card("Petrifying Meddler", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:own) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def cast_meddler
    p1.add_mana(blue: 5)
    p1.cast(card: meddler) { _1.pay_mana(generic: { blue: 4 }, blue: 1) }
  end

  def stuns(permanent) = permanent.counters.of_type(Magic::Counters::Stun).count

  it "is a devoid 4/5 with reach" do
    permanent = ResolvePermanent("Petrifying Meddler", owner: p1)
    expect(meddler.colors).to be_empty
    expect(permanent.power).to eq(4)
    expect(permanent.toughness).to eq(5)
    expect(permanent.has_keyword?(Magic::Cards::Keywords::REACH)).to be(true)
  end

  it "taps the target creature and stuns it when cast" do
    cast_meddler
    game.stack.resolve!
    game.resolve_choice!(target: bears)
    expect(bears.tapped?).to be(true)
    expect(stuns(bears)).to eq(1)
    expect(stuns(own)).to eq(0)
  end

  it "may choose no target" do
    cast_meddler
    game.stack.resolve!
    game.skip_choice!
    expect(bears.tapped?).to be(false)
    expect(stuns(bears)).to eq(0)
  end

  it "does not trigger when it enters without being cast" do
    ResolvePermanent("Petrifying Meddler", owner: p1)
    game.settle!
    expect(game.choices).to be_empty
    expect(stuns(bears)).to eq(0)
  end
end
