# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EchoesOfEternity do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:echoes) { ResolvePermanent("Echoes Of Eternity", owner: p1) }

  def search_prompts = game.choices.select { _1.is_a?(Magic::Cards::SolemnSimulacrum::MaySearchChoice) }

  it "makes a colorless permanent's trigger happen an additional time" do
    ResolvePermanent("Solemn Simulacrum", owner: p1)

    expect(search_prompts.size).to eq(1)
    game.skip_choice!
    game.settle!
    game.stack.resolve!
    expect(search_prompts.size).to eq(1)
    game.skip_choice!
    game.settle!
    game.stack.resolve!
    expect(search_prompts).to be_empty
  end

  it "does not double triggers for an opponent's colorless permanent" do
    ResolvePermanent("Solemn Simulacrum", owner: p2)
    game.skip_choice!
    game.settle!
    game.stack.resolve!

    expect(search_prompts).to be_empty
  end

  it "does not double its own triggers" do
    expect(echoes.controller).to eq(p1)
    expect(echoes.static_abilities.first.doubles_trigger_for?(echoes, nil)).to be(false)
  end

  it "copies a colorless spell when it is cast" do
    p1.add_mana(colorless: 4)
    p1.cast(card: Card("Solemn Simulacrum", owner: p1)) { |a| a.pay_mana(generic: { colorless: 4 }) }
    6.times do
      game.skip_choice! if game.choices.any?
      game.settle!
    end

    expect(p1.creatures.count { _1.name == "Solemn Simulacrum" }).to eq(2)
  end

  it "does not copy a coloured spell" do
    p1.add_mana(red: 1)
    p1.cast(card: Card("Shock", owner: p1)) { |a| a.pay_mana(red: 1); a.targeting(p2) }

    expect(game.stack.spells.size).to eq(1)
  end
end
