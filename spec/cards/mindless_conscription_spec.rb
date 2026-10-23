# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MindlessConscription do
  include_context "two player game"

  before { go_to_main_phase! }

  def armies = p1.creatures.select { _1.types.include?("Army") }

  it "amasses Zombies 3 when it enters" do
    ResolvePermanent("Mindless Conscription", owner: p1)
    game.settle!

    expect(armies.size).to eq(1)
    expect(armies.first.power).to eq(3)
    expect(armies.first.types).to include("Zombie")
  end

  it "amasses again when you draw your third card in a turn" do
    ResolvePermanent("Mindless Conscription", owner: p1)
    game.settle!
    # go_to_main_phase! already drew one card this turn.
    p1.draw!
    game.settle!
    expect(armies.first.power).to eq(3)

    p1.draw!
    game.settle!
    expect(armies.size).to eq(1)
    expect(armies.first.power).to eq(6)
  end

  it "ignores an opponent's third draw" do
    ResolvePermanent("Mindless Conscription", owner: p1)
    game.settle!
    3.times { p2.draw! }
    game.settle!

    expect(armies.first.power).to eq(3)
  end
end
