# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OcelotPride do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:pride) { ResolvePermanent("Ocelot Pride", owner: p1) }

  def cats = p1.creatures.select { _1.name == "Cat" }

  def end_turn!
    current_turn.end!
    game.settle!
  end

  it "has first strike and lifelink" do
    expect(pride.first_strike?).to eq(true)
    expect(pride.lifelink?).to eq(true)
  end

  it "creates a Cat at end step if you gained life this turn" do
    p1.gain_life(1)
    end_turn!

    expect(cats.size).to eq(1)
  end

  it "does nothing if you did not gain life" do
    end_turn!

    expect(cats).to be_empty
  end

  it "copies tokens that entered this turn with the city's blessing" do
    9.times { ResolvePermanent("Forest", owner: p1) }
    p1.gain_life(1)
    end_turn!

    expect(cats.size).to eq(2)
  end
end
