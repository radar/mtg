# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WaryWatchdog do
  include_context "two player game"

  def surveil_choices = game.choices.select { _1.is_a?(Magic::Choice::Surveil) }

  it "is a 3/1 Dog" do
    watchdog = ResolvePermanent("Wary Watchdog", owner: p1)
    skip_surveil
    expect([watchdog.power, watchdog.toughness]).to eq([3, 1])
    expect(watchdog.type?("Dog")).to eq(true)
  end

  def skip_surveil
    game.skip_choice! while surveil_choices.any?
  end

  it "surveils 1 when it enters" do
    ResolvePermanent("Wary Watchdog", owner: p1)
    choice = surveil_choices.first
    expect(choice).not_to be_nil
    expect(choice.amount).to eq(1)
  end

  it "surveils 1 when it dies" do
    watchdog = ResolvePermanent("Wary Watchdog", owner: p1)
    skip_surveil
    watchdog.destroy!
    game.settle!

    expect(surveil_choices.size).to eq(1)
  end
end
