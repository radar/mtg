# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VoiceOfTheWoods do
  include_context "two player game"

  let!(:voice) { ResolvePermanent("Voice Of The Woods", owner: p1) }

  it "is a 2/2 Elf" do
    expect(voice.power).to eq(2)
    expect(voice.toughness).to eq(2)
    expect(voice.type?("Elf")).to be true
  end

  it "taps five untapped Elves you control to create a 7/7 green Elemental token with trample" do
    elves = 4.times.map { ResolvePermanent("Llanowar Elves", owner: p1) }
    2.times { game.next_turn }
    go_to_main_phase!

    p1.activate_ability(ability: voice.activated_abilities.first) do |a|
      a.pay_multi_tap([voice] + elves)
    end
    game.stack.resolve!

    expect(voice).to be_tapped
    expect(elves).to all(be_tapped)

    tokens = p1.creatures.select { |c| c.name == "Elemental" && c.token? }
    expect(tokens.count).to eq(1)
    expect(tokens.first.power).to eq(7)
    expect(tokens.first.toughness).to eq(7)
    expect(tokens.first).to have_keyword(:trample)
  end
end
