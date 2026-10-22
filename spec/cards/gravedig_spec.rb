# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Gravedig do
  include_context "two player game"

  let(:card) { Card("Gravedig", owner: p1) }
  let!(:dead_bears) { Card("Grizzly Bears", owner: p1).tap { p1.graveyard.add(_1) } }

  before do
    p1.hand.add(card)
    go_to_main_phase!
  end

  def zombies(player) = player.creatures.select { _1.name == "Zombie" }

  def cast(entwine: false, modes: [])
    p1.add_mana(black: entwine ? 4 : 2)
    p1.cast(card: card) do |action|
      action.pay_mana(black: 1, generic: { black: 1 })
      action.pay_kicker(generic: { black: 2 }) if entwine
      modes.each { |mode, *targets| action.choose_mode(mode) { _1.targeting(*targets) } }
    end
    game.stack.resolve!
    game.settle!
  end

  it "has target player create a 2/2 black Zombie" do
    cast(modes: [[described_class::CreateZombie, p2]])

    zombie = zombies(p2).first
    expect([zombie.power, zombie.toughness]).to eq([2, 2])
    expect(zombie.colors).to eq([:black])
    expect(zombies(p1)).to be_empty
  end

  it "returns target creature card from your graveyard to your hand" do
    cast(modes: [[described_class::ReturnCreature, dead_bears]])

    expect(p1.hand.cards).to include(dead_bears)
    expect(p1.graveyard.cards).not_to include(dead_bears)
  end

  it "lets you choose only one mode without entwine" do
    expect do
      cast(modes: [[described_class::CreateZombie, p1], [described_class::ReturnCreature, dead_bears]])
    end.to raise_error(Magic::Actions::Cast::InvalidModes, /at most 1/)
  end

  it "does both modes when entwined" do
    cast(entwine: true, modes: [[described_class::CreateZombie, p1], [described_class::ReturnCreature, dead_bears]])

    expect(zombies(p1).size).to eq(1)
    expect(p1.hand.cards).to include(dead_bears)
  end
end
