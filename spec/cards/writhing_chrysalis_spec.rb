# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WrithingChrysalis do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:card) { Card("Writhing Chrysalis", owner: p1) }

  def spawns = p1.creatures.select { _1.name == "Eldrazi Spawn" }

  def counters(permanent) = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  it "is a devoid 2/3 reach Eldrazi Drone" do
    chrysalis = ResolvePermanent("Writhing Chrysalis", owner: p1)

    expect(chrysalis.colors).to be_empty
    expect([chrysalis.power, chrysalis.toughness]).to eq([2, 3])
    expect(chrysalis.has_keyword?(Magic::Cards::Keywords::REACH)).to be(true)
  end

  it "creates two 0/1 Eldrazi Spawn tokens when cast" do
    p1.add_mana(red: 3, green: 1)
    p1.cast(card: card) { _1.pay_mana(generic: { red: 2 }, red: 1, green: 1) }
    game.settle!

    expect(spawns.count).to eq(2)
    expect(spawns.map { [_1.power, _1.toughness] }.uniq).to eq([[0, 1]])
    expect(p1.creatures.map(&:name)).to include("Writhing Chrysalis")
  end

  it "creates no Spawn when it enters without being cast" do
    ResolvePermanent("Writhing Chrysalis", owner: p1)

    expect(spawns).to be_empty
  end

  context "on the battlefield with Spawn" do
    let!(:chrysalis) { ResolvePermanent("Writhing Chrysalis", owner: p1) }

    before do
      chrysalis.create_eldrazi_spawn(2)
      game.settle!
    end

    it "gets a counter whenever you sacrifice another Eldrazi" do
      spawns.first.sacrifice!
      game.settle!

      expect(counters(chrysalis)).to eq(1)

      spawns.first.sacrifice!
      game.settle!

      expect(counters(chrysalis)).to eq(2)
    end

    it "gets no counter when you sacrifice a non-Eldrazi" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      bears.sacrifice!
      game.settle!

      expect(counters(chrysalis)).to eq(0)
    end

    it "gets no counter when the opponent sacrifices an Eldrazi" do
      theirs = ResolvePermanent("Basking Broodscale", owner: p2)
      theirs.sacrifice!
      game.settle!

      expect(counters(chrysalis)).to eq(0)
    end

    it "gets no counter when it is itself sacrificed" do
      chrysalis.sacrifice!
      game.settle!

      expect(counters(chrysalis)).to eq(0)
    end
  end
end
