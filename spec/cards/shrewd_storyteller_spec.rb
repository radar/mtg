# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ShrewdStoryteller do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:storyteller) { ResolvePermanent("Shrewd Storyteller", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def to_second_main!
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.end_of_combat!
    current_turn.second_main!
    game.settle!
  end

  it "is a 3/3" do
    expect(storyteller.power).to eq(3)
    expect(storyteller.toughness).to eq(3)
  end

  it "puts a +1/+1 counter on target creature at second main if tapped" do
    storyteller.tap!
    to_second_main!
    game.resolve_choice!(target: bears)
    game.tick!
    expect(bears.power).to eq(3)
    expect(bears.toughness).to eq(3)
  end

  it "does nothing if untapped" do
    to_second_main!
    game.tick!
    expect(game.choices).to be_empty
    expect(bears.power).to eq(2)
  end
end
