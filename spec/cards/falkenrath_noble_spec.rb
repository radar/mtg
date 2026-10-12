# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FalkenrathNoble do
  include_context "two player game"

  let!(:noble) { ResolvePermanent("Falkenrath Noble", owner: p1) }

  it "has flying" do
    expect(noble).to have_keyword(:flying)
  end

  it "drains the chosen player when another creature dies" do
    ResolvePermanent("Grizzly Bears", owner: p2).destroy!
    game.settle!
    game.resolve_choice!(target: p2)
    game.settle!

    expect(p2.life).to eq(19)
    expect(p1.life).to eq(21)
  end

  it "triggers when it dies itself" do
    noble.destroy!
    game.settle!
    game.resolve_choice!(target: p2)
    game.settle!

    expect(p2.life).to eq(19)
  end
end
