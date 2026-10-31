# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheMouthOfSauron do
  include_context "two player game"
  before { go_to_main_phase! }

  def armies = p1.creatures.by_type("Army")

  def counters(creature) = creature.counters.of_type(Magic::Counters::Plus1Plus1).count

  def top(player, *names)
    names.reverse_each { |name| player.library.add(Card(name, owner: player)) }
  end

  def enter_mouth
    ResolvePermanent("The Mouth Of Sauron", owner: p1)
    game.settle!
  end

  it "is a legendary 3/4 Human Advisor" do
    mouth = ResolvePermanent("The Mouth Of Sauron", owner: p1)
    expect([mouth.power, mouth.toughness]).to eq([3, 4])
    expect(mouth.type?("Human")).to eq(true)
    expect(mouth.type?("Advisor")).to eq(true)
    expect(mouth.legendary?).to eq(true)
  end

  it "offers both players as targets" do
    enter_mouth
    expect(game.choices.last.choices).to contain_exactly(p1, p2)
  end

  it "mills the target player three cards" do
    top(p2, "Grizzly Bears", "Grizzly Bears", "Grizzly Bears")
    before_count = p2.graveyard.cards.count
    enter_mouth
    game.resolve_choice!(target: p2)
    game.settle!
    expect(p2.graveyard.cards.count).to eq(before_count + 3)
    expect(p1.graveyard.cards).to be_empty
  end

  it "amasses Orcs X counting milled instants and sorceries in the target's graveyard" do
    p2.graveyard.add(Card("Lightning Bolt", owner: p2))
    top(p2, "Opt", "Grizzly Bears", "Burst Lightning")
    enter_mouth
    game.resolve_choice!(target: p2)
    game.settle!
    expect(armies.size).to eq(1)
    expect(armies.first.type?("Orc")).to eq(true)
    expect(counters(armies.first)).to eq(3)
  end

  it "counts the target's graveyard, not the controller's" do
    p1.graveyard.add(Card("Lightning Bolt", owner: p1))
    top(p2, "Opt", "Grizzly Bears", "Grizzly Bears")
    enter_mouth
    game.resolve_choice!(target: p2)
    game.settle!
    expect(counters(armies.first)).to eq(1)
  end

  it "can target its controller and counts their graveyard" do
    p1.graveyard.add(Card("Lightning Bolt", owner: p1))
    top(p1, "Grizzly Bears", "Grizzly Bears", "Grizzly Bears")
    enter_mouth
    game.resolve_choice!(target: p1)
    game.settle!
    expect(counters(armies.first)).to eq(1)
  end

  it "makes no surviving Army when X is 0" do
    top(p2, "Grizzly Bears", "Grizzly Bears", "Grizzly Bears")
    enter_mouth
    game.resolve_choice!(target: p2)
    game.settle!
    expect(armies).to be_empty
  end

  it "adds to an existing Army" do
    Magic::Amass.call(source: p1.library.cards.first, controller: p1, amount: 1, subtype: "Orc")
    game.tick!
    top(p2, "Opt", "Opt", "Grizzly Bears")
    enter_mouth
    game.resolve_choice!(target: p2)
    game.settle!
    expect(armies.size).to eq(1)
    expect(counters(armies.first)).to eq(3)
  end
end
