# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WardenOfTheGrove do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:permanent) { ResolvePermanent("Warden Of The Grove", owner: p1) }

  def counters(creature) = creature.counters.of_type(Magic::Counters::Plus1Plus1).count

  it "puts a +1/+1 counter on itself at the beginning of your end step" do
    current_turn.end!
    game.settle!
    expect(counters(permanent)).to eq(1)
  end

  it "makes another nontoken creature you control endure X, X being its counters" do
    permanent.add_counter("+1/+1", amount: 2)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    game.resolve_choice!
    expect(counters(bears)).to eq(2)
  end

  it "or creates an X/X Spirit token" do
    permanent.add_counter("+1/+1", amount: 2)
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.skip_choice!
    token = p1.permanents.find { _1.name == "Spirit" }
    expect([token.power, token.toughness]).to eq([2, 2])
  end

  it "ignores creature tokens and creatures an opponent controls" do
    permanent.add_counter("+1/+1", amount: 2)
    Magic::Choice::Endure::SpiritToken.new(game:, owner: p1).resolve!
    ResolvePermanent("Grizzly Bears", owner: p2)
    game.settle!
    expect(game.choices).to be_empty
  end
end
