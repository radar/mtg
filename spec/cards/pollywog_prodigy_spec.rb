# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PollywogProdigy do
  include_context "two player game"

  let!(:prodigy) { ResolvePermanent("Pollywog Prodigy", owner: p1) }

  it "is a 1/3" do
    expect([prodigy.power, prodigy.toughness]).to eq([1, 3])
  end

  it "evolves when a creature with greater power enters" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.tick!

    expect([prodigy.power, prodigy.toughness]).to eq([2, 4])
  end

  it "does not evolve for a creature with no greater power or toughness" do
    ResolvePermanent("Llanowar Elves", owner: p1)
    game.tick!

    expect([prodigy.power, prodigy.toughness]).to eq([1, 3])
  end

  it "does not evolve for an opponent's creature" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    game.tick!

    expect(prodigy.power).to eq(1)
  end

  def cast_path_by_p2(target)
    spell = Card("Path To Exile", owner: p2)
    p2.hand.add(spell)
    p2.add_mana(white: 1)
    p2.cast(card: spell) do |action|
      action.targeting(target)
      action.pay_mana(white: 1)
    end
    game.settle!
  end

  it "draws when an opponent casts a noncreature spell with mana value below its power" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    game.tick!
    expect(prodigy.power).to eq(2)

    expect { cast_path_by_p2(bears) }.to change { p1.hand.count }.by(1)
  end

  it "does not draw when the spell's mana value is not below its power" do
    expect(prodigy.power).to eq(1)

    expect { cast_path_by_p2(prodigy) }.not_to change { p1.hand.count }
  end

  it "does not draw for its own controller's noncreature spell" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    game.tick!
    spell = Card("Path To Exile", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(white: 1)
    hand_before = p1.hand.count

    p1.cast(card: spell) do |action|
      action.targeting(bears)
      action.pay_mana(white: 1)
    end
    game.settle!

    # The spell left the hand and nothing was drawn.
    expect(p1.hand.count).to eq(hand_before - 1)
  end
end
