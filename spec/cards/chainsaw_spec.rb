# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Chainsaw do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:opp_bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def rev_counters(chainsaw) = chainsaw.counters.of_type(Magic::Counters::Rev).count

  it "deals 3 damage to up to one target creature when it enters" do
    ResolvePermanent("Chainsaw", owner: p1)
    game.settle!
    game.resolve_choice!(target: opp_bears)
    game.settle!

    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "may target no creature" do
    ResolvePermanent("Chainsaw", owner: p1)
    game.settle!
    game.skip_choice!
    game.settle!

    expect(opp_bears.damage).to eq(0)
    expect(game.choices).to be_empty
  end

  context "once it is on the battlefield" do
    let!(:chainsaw) do
      ResolvePermanent("Chainsaw", owner: p1).tap do
        game.settle!
        game.skip_choice!
        game.settle!
      end
    end

    it "starts with no rev counters" do
      expect(rev_counters(chainsaw)).to eq(0)
    end

    it "gets a rev counter whenever a creature dies" do
      opp_bears.destroy!
      game.settle!

      expect(rev_counters(chainsaw)).to eq(1)
    end

    it "gives the equipped creature +X/+0 where X is the number of rev counters" do
      chainsaw.attach_to!(bears)
      opp_bears.destroy!
      game.settle!
      game.tick!

      expect([bears.power, bears.toughness]).to eq([3, 2])
    end
  end
end
