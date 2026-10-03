# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EruditeWizard do
  include_context "two player game"

  let!(:wizard) { ResolvePermanent("Erudite Wizard", owner: p1) }

  def draw!(player, times = 1)
    times.times do
      player.draw!
      game.settle!
    end
  end

  it "is a 2/3 Human Wizard" do
    expect([wizard.power, wizard.toughness]).to eq([2, 3])
  end

  it "gets a +1/+1 counter when you draw your second card each turn" do
    draw!(p1)
    expect(wizard.power).to eq(2)

    draw!(p1)
    expect(wizard.power).to eq(3)
  end

  it "does not get another counter for a third or fourth card" do
    draw!(p1, 4)

    expect(wizard.power).to eq(3)
  end

  it "counts the draw step's card as the first" do
    go_to_main_phase!
    draw!(p1)

    expect(wizard.power).to eq(3)
  end

  it "counts again on the next turn" do
    draw!(p1, 2)
    current_turn.end!
    current_turn.cleanup!
    resolve_cleanup_discards!
    game.next_turn
    game.next_turn
    draw!(p1, 2)

    expect(wizard.power).to eq(4)
  end

  it "ignores the opponent's draws" do
    draw!(p2, 2)

    expect(wizard.power).to eq(2)
  end
end
