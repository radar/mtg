# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GlamerGifter do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:gifter) { ResolvePermanent("Glamer Gifter", owner: p1) }
  let(:choice) { game.choices.last }

  it "is a 1/2 Faerie Wizard with flash and flying" do
    expect(gifter.power).to eq(1)
    expect(gifter.toughness).to eq(2)
    expect(gifter.type?("Faerie")).to eq(true)
    expect(gifter.type?("Wizard")).to eq(true)
    expect(gifter).to have_keyword(:flash)
    expect(gifter).to have_keyword(:flying)
  end

  it "lets you choose another creature, never itself" do
    expect(choice.choices).to eq([bears])
  end

  it "makes the chosen creature a 4/4 with all creature types until end of turn" do
    game.resolve_choice!(target: bears)
    game.tick!

    expect(bears.power).to eq(4)
    expect(bears.toughness).to eq(4)
    expect(bears.type?("Goblin")).to eq(true)
    expect(bears.type?("Elf")).to eq(true)
  end

  it "wears off at end of turn" do
    game.resolve_choice!(target: bears)
    game.tick!
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect(bears.power).to eq(2)
    expect(bears.toughness).to eq(2)
    expect(bears.type?("Goblin")).to eq(false)
  end

  it "may choose no creature" do
    game.skip_choice!
    game.tick!

    expect(bears.power).to eq(2)
    expect(bears.type?("Goblin")).to eq(false)
  end
end
