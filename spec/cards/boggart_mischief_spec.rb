# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BoggartMischief do
  include_context "two player game"
  before { go_to_main_phase! }

  def goblin_tokens = p1.permanents.select { |permanent| permanent.name == "Goblin" }

  it "is a Kindred Enchantment — Goblin" do
    expect(Card("Boggart Mischief").types).to include("Enchantment", "Goblin")
  end

  it "may blight 1 when it enters; if it does, creates two 1/1 black and red Goblin tokens" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Boggart Mischief", owner: p1)

    game.resolve_choice! # accept the "may"
    game.resolve_choice!(target: bears)

    expect(bears.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(1)
    expect(goblin_tokens.count).to eq(2)
  end

  it "does nothing when declined" do
    ResolvePermanent("Boggart Mischief", owner: p1)

    game.skip_choice!

    expect(goblin_tokens.count).to eq(0)
  end

  it "drains 1 life whenever a Goblin you control dies" do
    ResolvePermanent("Boggart Mischief", owner: p1)
    game.skip_choice!
    goblin = ResolvePermanent("Bile-Vial Boggart", owner: p1)

    goblin.destroy!
    game.settle!
    game.skip_choice! # decline Bile-Vial Boggart's own "up to one target creature" death trigger

    expect(p1.life).to eq(21)
    expect(p2.life).to eq(19)
  end

  it "doesn't trigger for a non-Goblin creature dying" do
    ResolvePermanent("Boggart Mischief", owner: p1)
    game.skip_choice!
    bears = ResolvePermanent("Grizzly Bears", owner: p1)

    bears.destroy!
    game.settle!

    expect(p1.life).to eq(20)
    expect(p2.life).to eq(20)
  end
end
