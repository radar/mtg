# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThranduilsCompany do
  include_context "two player game"

  let!(:company) { ResolvePermanent("Thranduil's Company", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before { go_to_main_phase! }

  def play_forest
    forest = Card("Forest", owner: p1)
    p1.hand.add(forest)
    p1.play_land(land: forest)
    game.settle!
  end

  it "puts two +1/+1 counters on a target creature you control and gives vigilance on landfall" do
    play_forest
    game.resolve_choice!(target: bears)
    game.tick!

    expect([bears.power, bears.toughness]).to eq([4, 4])
    expect(bears).to have_keyword(:vigilance)
  end

  it "does not trigger for an opponent's land" do
    go_to_main_phase_for!(p2)
    forest = Card("Forest", owner: p2)
    p2.hand.add(forest)
    p2.play_land(land: forest)
    game.settle!

    expect(game.choices).to be_empty
  end

  it "allows only one land per turn without another Elf" do
    expect(p1.max_lands_per_turn).to eq(1)
  end

  it "allows an additional land while you control another Elf" do
    ResolvePermanent("Wood Elves", owner: p1)

    expect(p1.max_lands_per_turn).to eq(2)
  end
end
