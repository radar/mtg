# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LoxodonBattlePriest do
  include_context "two player game"

  let!(:priest) { ResolvePermanent("Loxodon Battle Priest", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "is a 3/5" do
    expect([priest.power, priest.toughness]).to eq([3, 5])
  end

  it "puts a +1/+1 counter on another creature (never itself) at the beginning of combat on your turn" do
    skip_to_combat!
    game.settle!
    game.tick!

    expect(bears.power).to eq(3)
    expect(priest.power).to eq(3)
  end

  it "lets you choose among several other creatures" do
    other = ResolvePermanent("Wood Elves", owner: p1)
    skip_to_combat!
    expect(game.choices.last.choices).to contain_exactly(bears, other)
    game.resolve_choice!(target: other)
    game.tick!
    expect(other.power).to eq(2)
    expect(bears.power).to eq(2)
  end

  it "does not trigger on the opponent's turn" do
    go_to_main_phase_for!(p2)
    current_turn.beginning_of_combat!
    game.settle!
    game.tick!
    expect(bears.power).to eq(2)
  end
end
