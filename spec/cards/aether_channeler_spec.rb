# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AetherChanneler do
  include_context "two player game"

  let(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def cast_channeler
    ResolvePermanent("Aether Channeler", owner: p1)
  end

  it "offers three modes" do
    cast_channeler
    expect(game.choices.last.modes.keys).to eq(%i[bird bounce draw])
  end

  it "creates a 1/1 white Bird with flying" do
    cast_channeler
    game.resolve_choice!(mode: :bird)

    bird = p1.creatures.find { _1.name == "Bird" && _1.token? }
    expect([bird.power, bird.toughness]).to eq([1, 1])
    expect(bird).to be_flying
    expect(bird.colors).to eq([:white])
  end

  it "draws a card" do
    cast_channeler
    expect { game.resolve_choice!(mode: :draw) }.to change { p1.hand.count }.by(1)
  end

  it "returns another target nonland permanent to its owner's hand" do
    bears
    ResolvePermanent("Plains", owner: p1)
    cast_channeler
    game.resolve_choice!(mode: :bounce)

    choice = game.choices.last
    expect(choice.choices).to contain_exactly(bears)
    game.resolve_choice!(target: bears)

    expect(p2.hand.map(&:name)).to include("Grizzly Bears")
  end

  it "never offers itself or a land to bounce" do
    ResolvePermanent("Forest", owner: p2)
    channeler = cast_channeler
    game.resolve_choice!(mode: :bounce)

    expect(game.choices).to be_empty
    expect(p1.permanents).to include(channeler)
  end

  it "rejects an unknown mode" do
    cast_channeler
    expect { game.resolve_choice!(mode: :nope) }.to raise_error(ArgumentError)
  end
end
