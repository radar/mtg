# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StromkirkBloodthief do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bloodthief) { ResolvePermanent("Stromkirk Bloodthief", owner: p1) }
  let!(:other_vampire) { ResolvePermanent("Bishop's Soldier", owner: p1) } # Vampire Soldier
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def counters(permanent) = permanent.counters.of_type(Magic::Counters["+1/+1"]).count

  def end_step!
    current_turn.end!
    game.settle!
  end

  it "is a 2/2 Vampire Rogue" do
    expect([bloodthief.power, bloodthief.toughness]).to eq([2, 2])
  end

  it "puts a +1/+1 counter on target Vampire you control at your end step if an opponent lost life this turn" do
    p2.lose_life(1)
    end_step!
    game.resolve_choice!(target: other_vampire)

    expect(counters(other_vampire)).to eq(1)
  end

  it "can put the counter on itself" do
    p2.lose_life(1)
    end_step!
    game.resolve_choice!(target: bloodthief)

    expect(counters(bloodthief)).to eq(1)
  end

  it "can't target a non-Vampire" do
    p2.lose_life(1)
    end_step!

    expect(game.choices.last.choices).not_to include(bears)
  end

  it "does nothing if no opponent lost life this turn" do
    end_step!

    expect(game.choices).to be_empty
  end

  it "does nothing if only you lost life" do
    p1.lose_life(2)
    end_step!

    expect(game.choices).to be_empty
  end
end
