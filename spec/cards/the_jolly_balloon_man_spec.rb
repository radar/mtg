# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheJollyBalloonMan do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:clown) { ResolvePermanent("The Jolly Balloon Man", owner: p1) }
  let!(:angel) { ResolvePermanent("Baneslayer Angel", owner: p1) }

  def copy!(target)
    p1.add_mana(red: 1)
    p1.activate_ability(ability: clown.activated_abilities.first) do |action|
      action.pay_mana(generic: { red: 1 })
      action.targeting(target)
    end
    game.stack.resolve!
    game.settle!
  end

  def balloons = p1.creatures.select { _1.type?("Balloon") }

  it "is a legendary 1/4 Human Clown with haste" do
    expect([clown.power, clown.toughness]).to eq([1, 4])
    expect(clown).to have_keyword(:haste)
  end

  it "creates a 1/1 copy of another creature you control with flying and haste" do
    copy!(angel)

    token = balloons.first
    expect(token).to be_token
    expect(token.name).to eq("Baneslayer Angel")
    expect([token.power, token.toughness]).to eq([1, 1])
    expect(token).to have_keyword(:flying)
    expect(token).to have_keyword(:haste)
  end

  it "makes the copy red and a Balloon in addition to its other colors and types" do
    copy!(angel)

    token = balloons.first
    expect(token.colors).to contain_exactly(:white, :red)
    expect(token.type?("Angel")).to be(true)
    expect(token.type?("Balloon")).to be(true)
  end

  it "keeps the copied creature's abilities" do
    copy!(angel)

    expect(balloons.first).to have_keyword(:lifelink)
  end

  it "sacrifices the token at the beginning of the next end step" do
    copy!(angel)
    token = balloons.first
    current_turn.end!
    game.settle!

    expect(token.zone).to be_nil
    expect(balloons).to be_empty
  end

  it "can't copy itself" do
    ability = clown.activated_abilities.first

    expect(ability.target_choices).to contain_exactly(angel)
  end

  it "can only be activated as a sorcery" do
    game.next_turn
    go_to_main_phase!

    expect(clown.activated_abilities.first).not_to be_requirements_met
  end
end
