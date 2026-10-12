# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BothersomeNoisemaker do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:noisemaker) { ResolvePermanent("Bothersome Noisemaker", owner: p1) }

  def armies = p1.creatures.select { _1.types.include?("Army") }

  def cast_shock
    p1.add_mana(red: 1)
    p1.cast(card: Card("Shock", owner: p1)) { |a| a.pay_mana(red: 1).targeting(p2) }
    game.settle!
  end

  it "is a 2/2 Goblin Bard" do
    expect([noisemaker.power, noisemaker.toughness]).to eq([2, 2])
    expect(noisemaker.card.types).to include("Goblin", "Bard")
  end

  it "creates a Goblin Army with a +1/+1 counter when you cast a noncreature spell" do
    cast_shock
    game.tick!

    expect(armies.size).to eq(1)
    expect(armies.first.types).to include("Goblin")
    expect([armies.first.power, armies.first.toughness]).to eq([1, 1])
  end

  it "adds to the same Army on later noncreature spells" do
    cast_shock
    game.stack.resolve! until game.stack.empty?
    cast_shock
    game.tick!

    expect(armies.size).to eq(1)
    expect(armies.first.power).to eq(2)
  end

  it "ignores creature spells" do
    p1.add_mana(green: 2)
    p1.cast(card: Card("Grizzly Bears", owner: p1)) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    game.settle!

    expect(armies).to be_empty
  end
end
