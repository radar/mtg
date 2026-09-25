# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TamMindfulFirstYear do
  include_context "two player game"

  let!(:tam) { ResolvePermanent("Tam, Mindful First-Year", owner: p1) }
  let!(:elves) { ResolvePermanent("Wood Elves", owner: p1) }

  before { game.tick! }

  it "is a legendary 2/2 Gorgon Wizard with a hybrid {1}{G/U} cost" do
    expect(tam).to be_legendary
    expect([tam.power, tam.toughness]).to eq([2, 2])
    expect(tam).to be_type("Gorgon")
    expect(tam.mana_value).to eq(2)
    expect(tam.colors).to contain_exactly(:green, :blue)
  end

  it "gives each other creature you control hexproof from each of its colors" do
    expect(elves).to be_hexproof_from(:green)
    expect(elves).not_to be_hexproof_from(:blue)
    expect(tam).not_to be_hexproof_from(:green)
  end

  it "doesn't give an opponent's creatures hexproof" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    game.tick!
    expect(bears).not_to be_hexproof_from(:green)
  end

  it "makes a creature you control all colors until end of turn, so it has hexproof from each color" do
    go_to_main_phase!
    p1.activate_ability(ability: tam.activated_abilities.first) { _1.targeting(elves) }
    game.stack.resolve!
    game.tick!

    expect(elves.colors).to contain_exactly(:white, :blue, :black, :red, :green)
    %i[white blue black red green].each { expect(elves).to be_hexproof_from(_1) }
    expect(tam).to be_tapped

    current_turn.end!
    current_turn.cleanup!
    game.tick!
    expect(elves.colors).to eq([:green])
    expect(elves).not_to be_hexproof_from(:red)
  end

  it "can't target an opponent's creature" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    expect(tam.activated_abilities.first.target_choices).not_to include(bears)
  end
end
