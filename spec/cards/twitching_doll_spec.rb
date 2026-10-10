# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TwitchingDoll do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:doll) { ResolvePermanent("Twitching Doll", owner: p1) }

  def spiders = p1.creatures.select { _1.name == "Spider" }

  def tap_for_mana!(color = :blue)
    doll.untap!
    p1.activate_ability(ability: doll.activated_abilities.first) { |a| a.choose(color) }
    game.settle!
  end

  def sacrifice!
    doll.untap!
    p1.activate_ability(ability: doll.activated_abilities.last)
    game.stack.resolve!
    game.settle!
  end

  it "is a 2/2 artifact creature" do
    expect([doll.power, doll.toughness]).to eq([2, 2])
    expect(doll).to be_artifact
  end

  it "taps for one mana of any color and gets a nest counter" do
    tap_for_mana!(:red)

    expect(p1.mana_pool[:red]).to eq(1)
    expect(doll.counters.of_type(Magic::Counters::Nest).count).to eq(1)
  end

  it "sacrifices for a 2/2 reach Spider token per counter" do
    2.times { tap_for_mana! }
    sacrifice!

    expect(p1.graveyard.cards.map(&:name)).to eq(["Twitching Doll"])
    expect(spiders.count).to eq(2)
    expect(spiders.first).to be_reach
    expect([spiders.first.power, spiders.first.toughness]).to eq([2, 2])
  end

  it "creates nothing with no counters" do
    sacrifice!

    expect(spiders).to be_empty
  end

  it "can only be sacrificed as a sorcery" do
    tap_for_mana!
    current_turn.end!

    expect { sacrifice! }.to raise_error(StandardError)
  end
end
