# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GlimmerSeeker do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:seeker) { ResolvePermanent("Glimmer Seeker", owner: p1) }

  def glimmers = p1.creatures.select { _1.type?("Glimmer") }

  def to_second_main!
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.end_of_combat!
    current_turn.second_main!
    game.settle!
  end

  it "is a 3/3 Human Survivor" do
    expect([seeker.power, seeker.toughness]).to eq([3, 3])
    expect(seeker.type?("Survivor")).to be true
  end

  it "creates a 1/1 Glimmer enchantment creature at second main if tapped and you control no Glimmer" do
    seeker.tap!
    expect { to_second_main! }.not_to(change { p1.hand.count })

    expect(glimmers.size).to eq(1)
    expect([glimmers.first.power, glimmers.first.toughness]).to eq([1, 1])
    expect(glimmers.first.type?("Enchantment")).to be true
  end

  it "draws a card instead if you control a Glimmer creature" do
    ResolvePermanent("Lionheart Glimmer", owner: p1)
    seeker.tap!

    expect { to_second_main! }.to change { p1.hand.count }.by(1)
    expect(glimmers.size).to eq(1)
  end

  it "does nothing if untapped" do
    expect { to_second_main! }.not_to(change { p1.hand.count })
    expect(glimmers).to be_empty
  end
end
