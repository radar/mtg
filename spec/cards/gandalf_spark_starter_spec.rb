# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GandalfSparkStarter do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:gandalf) { ResolvePermanent("Gandalf, Spark Starter", owner: p1) }

  it "is a 4/3 reach Avatar Wizard" do
    expect([gandalf.power, gandalf.toughness]).to eq([4, 3])
    expect(gandalf.has_keyword?(Magic::Cards::Keywords::REACH)).to eq(true)
  end

  it "deals 3 damage divided among its targets when it enters" do
    expect { game.resolve_choice!(distribution: { bears => 2, p2 => 1 }) }.to change { p2.life }.by(-1)
    game.settle!
    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "can put all 3 damage on one target" do
    expect { game.resolve_choice!(distribution: { p2 => 3 }) }.to change { p2.life }.by(-3)
  end

  it "rejects a division that isn't 3 damage" do
    expect { game.choices.last.resolve!(distribution: { p2 => 2 }) }.to raise_error(ArgumentError)
  end
end
