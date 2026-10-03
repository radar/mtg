# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ValkyriesCall do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:call) { ResolvePermanent("Valkyrie's Call", owner: p1) }

  def counters(permanent) = permanent.counters.of_type(Magic::Counters["+1/+1"]).count

  def returned(name = "Grizzly Bears", player = p1) = player.creatures.find { _1.name == name }

  it "is a 5 mana white enchantment" do
    expect(call.type?("Enchantment")).to eq(true)
    expect(call.card.cost.cost).to eq(generic: 3, white: 2)
  end

  it "returns a nontoken creature you control when it dies, with a +1/+1 counter, flying and Angel type" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    bears.destroy!
    game.settle!

    back = returned
    expect(back).not_to be_nil
    expect(back).not_to equal(bears)
    expect(counters(back)).to eq(1)
    expect([back.power, back.toughness]).to eq([3, 3])
    expect(back).to be_flying
    expect(back.type?("Angel")).to eq(true)
    expect(back.type?("Bear")).to eq(true)
    expect(p1.graveyard.cards.map(&:name)).not_to include("Grizzly Bears")
  end

  it "keeps flying and the Angel type past end of turn" do
    ResolvePermanent("Grizzly Bears", owner: p1).destroy!
    game.settle!
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect(returned).to be_flying
    expect(returned.type?("Angel")).to eq(true)
  end

  it "does not return an Angel when it dies" do
    ResolvePermanent("Grizzly Bears", owner: p1).destroy!
    game.settle!
    returned.destroy!
    game.settle!

    expect(returned).to be_nil
    expect(p1.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "does not return a creature that was already an Angel" do
    angel = ResolvePermanent("Baneslayer Angel", owner: p1)
    angel.destroy!
    game.settle!

    expect(returned("Baneslayer Angel")).to be_nil
  end

  it "does not return a token" do
    token = Magic::Permanent.resolve(game:, owner: p1, card: ResolvePermanent("Grizzly Bears", owner: p2).copiable_card, token: true, copy: true, cast: false)
    token.destroy!
    game.settle!

    expect(p1.creatures.select { _1.name == "Grizzly Bears" }).to be_empty
  end

  it "does not return an opponent's creature" do
    ResolvePermanent("Grizzly Bears", owner: p2).destroy!
    game.settle!

    expect(returned("Grizzly Bears", p2)).to be_nil
    expect(returned).to be_nil
  end
end
