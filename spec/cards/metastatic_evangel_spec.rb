# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MetastaticEvangel do
  include_context "two player game"

  let!(:evangel) { ResolvePermanent("Metastatic Evangel", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before do
    game.skip_choice! # Grizzly Bears entering proliferates too
    bears.add_counter("+1/+1")
    game.settle!
  end

  def plus_counters = bears.counters.of_type(Magic::Counters::Plus1Plus1).count

  it "proliferates when another nontoken creature enters under your control" do
    ResolvePermanent("Wood Elves", owner: p1)
    game.settle!
    game.resolve_choice!(chosen: [bears])

    expect(plus_counters).to eq(2)
  end

  it "does not proliferate for creatures an opponent controls" do
    ResolvePermanent("Wood Elves", owner: p2)
    game.settle!

    expect(game.choices).to be_empty
    expect(plus_counters).to eq(1)
  end

  it "does not proliferate for creature tokens" do
    evangel.trigger_effect(:create_token, token_class: Magic::Cards::Drossclaw::PhyrexianGermToken, controller: p1)
    game.settle!

    expect(game.choices).to be_empty
    expect(plus_counters).to eq(1)
  end
end
