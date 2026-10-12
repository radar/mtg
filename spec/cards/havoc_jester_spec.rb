# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HavocJester do
  include_context "two player game"

  let!(:jester) { ResolvePermanent("Havoc Jester", owner: p1) }

  it "is a 5/5 Devil" do
    expect([jester.power, jester.toughness]).to eq([5, 5])
  end

  it "deals 1 damage to any target whenever you sacrifice a permanent" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    bears.sacrifice!
    game.settle!
    game.resolve_choice!(target: p2)
    game.settle!

    expect(p2.life).to eq(19)
  end

  it "doesn't trigger when an opponent sacrifices a permanent" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    bears.sacrifice!
    game.settle!

    expect(game.choices).to be_empty
  end

  it "doesn't trigger when a permanent is destroyed" do
    ResolvePermanent("Grizzly Bears", owner: p1).destroy!
    game.settle!

    expect(game.choices).to be_empty
  end
end
