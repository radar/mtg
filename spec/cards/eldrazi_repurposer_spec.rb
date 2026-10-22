# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EldraziRepurposer do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:repurposer) { Card("Eldrazi Repurposer", owner: p1) }

  def spawns = p1.creatures.select { _1.name == "Eldrazi Spawn" }

  def cast_repurposer
    p1.add_mana(green: 3)
    p1.cast(card: repurposer) { _1.pay_mana(generic: { green: 2 }, green: 1) }
  end

  it "is a devoid 3/3 Eldrazi Drone" do
    permanent = ResolvePermanent("Eldrazi Repurposer", owner: p1)

    expect(permanent.colors).to be_empty
    expect([permanent.power, permanent.toughness]).to eq([3, 3])
    expect(permanent.type?("Drone")).to be(true)
  end

  it "creates a 0/1 Eldrazi Spawn when cast, before it resolves" do
    cast_repurposer
    expect(game.stack.map { _1.is_a?(Magic::TriggeredAbility) ? _1.class : _1.card })
      .to eq([described_class::CastTrigger, repurposer])

    game.settle!

    expect(spawns.count).to eq(1)
    expect([spawns.first.power, spawns.first.toughness]).to eq([0, 1])
    expect(p1.creatures.map(&:name)).to include("Eldrazi Repurposer")
  end

  it "creates another Spawn when it dies" do
    cast_repurposer
    game.settle!
    expect(spawns.count).to eq(1)

    p1.creatures.find { _1.name == "Eldrazi Repurposer" }.destroy!
    game.settle!

    expect(p1.graveyard.cards.map(&:name)).to include("Eldrazi Repurposer")
    expect(spawns.count).to eq(2)
  end

  it "does not make a Spawn on entering without being cast" do
    ResolvePermanent("Eldrazi Repurposer", owner: p1)

    expect(spawns).to be_empty
  end
end
