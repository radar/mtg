# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AmphibianDownpour do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:dreadmaw) { ResolvePermanent("Colossal Dreadmaw", owner: p2) }

  def cast_downpour(target)
    p1.add_mana(blue: 3)
    p1.cast(card: Card("Amphibian Downpour", owner: p1)) { |a| a.pay_mana(generic: { blue: 2 }, blue: 1).targeting(target) }
  end

  it "turns the enchanted creature into a blue Frog 1/1 with no abilities" do
    cast_downpour(dreadmaw)
    game.stack.resolve!
    game.tick!

    expect(dreadmaw.power).to eq(1)
    expect(dreadmaw.toughness).to eq(1)
    expect(dreadmaw.types.map(&:to_s)).to include("Frog")
    expect(dreadmaw.colors).to eq([:blue])
  end

  it "removes the enchanted creature's abilities" do
    expect(dreadmaw).to have_keyword(Magic::Keywords::TRAMPLE)

    cast_downpour(dreadmaw)
    game.stack.resolve!
    game.tick!

    expect(dreadmaw).not_to have_keyword(Magic::Keywords::TRAMPLE)
  end

  it "has flash" do
    expect(Card("Amphibian Downpour", owner: p1)).to have_keyword(Magic::Keywords::FLASH)
  end

  it "makes no copy as the first spell cast this turn" do
    cast_downpour(dreadmaw)

    expect(game.choices).to be_empty
  end

  it "copies itself for each spell cast before it this turn" do
    p1.add_mana(red: 1)
    p1.cast(card: Card("Shock", owner: p1)) { |a| a.pay_mana(red: 1).targeting(p2) }
    game.stack.resolve!

    cast_downpour(dreadmaw)
    game.settle!
    game.stack.resolve!
    game.resolve_choice!(target: bears)
    game.stack.resolve!
    game.tick!

    expect(dreadmaw.power).to eq(1)
    expect(bears.power).to eq(1)
    expect(bears.attachments.count(&:token?)).to eq(1)
  end
end
