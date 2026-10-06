# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RapidHybridization do
  include_context "two player game"

  def cast(target)
    card = Card("Rapid Hybridization", owner: p1)
    p1.hand.add(card)
    p1.add_mana(blue: 1)
    p1.cast(card:) { |a| a.pay_mana(blue: 1).targeting(target) }
    game.stack.resolve!
    game.settle!
  end

  def frogs(player) = player.creatures.select { _1.name == "Frog Lizard" && _1.token? }

  it "destroys the creature and gives its controller a 3/3 green Frog Lizard" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    cast(bears)

    expect(bears.zone).not_to be_a(Magic::Zones::Battlefield)
    expect(frogs(p2).count).to eq(1)
    expect([frogs(p2).first.power, frogs(p2).first.toughness]).to eq([3, 3])
    expect(frogs(p2).first.colors).to eq([:green])
    expect(frogs(p1)).to be_empty
  end

  it "gives you the Frog when you destroy your own creature" do
    cast(ResolvePermanent("Grizzly Bears", owner: p1))

    expect(frogs(p1).count).to eq(1)
  end

  it "can't be regenerated" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    bears.regenerate!
    cast(bears)

    expect(bears.zone).not_to be_a(Magic::Zones::Battlefield)
  end

  it "still makes the Frog when the creature is indestructible" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    bears.grant_indestructible!
    game.tick!
    cast(bears)

    expect(bears.zone).to be_a(Magic::Zones::Battlefield)
    expect(frogs(p2).count).to eq(1)
  end
end
