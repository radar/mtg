# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BloodArtist do
  include_context "two player game"

  let!(:artist) { ResolvePermanent("Blood Artist", owner: p1) }

  it "drains the chosen player when another creature dies" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    bears.destroy!
    game.settle!
    game.resolve_choice!(target: p2)
    game.settle!

    expect(p2.life).to eq(19)
    expect(p1.life).to eq(21)
  end

  it "triggers when it dies itself" do
    artist.destroy!
    game.settle!
    game.resolve_choice!(target: p2)
    game.settle!

    expect(p2.life).to eq(19)
    expect(p1.life).to eq(21)
  end

  it "can target its controller" do
    ResolvePermanent("Grizzly Bears", owner: p1).destroy!
    game.settle!
    game.resolve_choice!(target: p1)
    game.settle!

    expect(p1.life).to eq(20)
  end
end
