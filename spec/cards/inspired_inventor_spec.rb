# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::InspiredInventor do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:opp_bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:inventor) { ResolvePermanent("Inspired Inventor", owner: p1) }

  def counters(permanent) = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  def servos = p1.creatures.select { _1.name == "Servo" }

  it "is a 2/2 Human Artificer" do
    expect([inventor.power, inventor.toughness]).to eq([2, 2])
    expect(inventor.type?("Human")).to be(true)
    expect(inventor.type?("Artificer")).to be(true)
  end

  it "offers the three modes when it enters" do
    expect(game.choices.first.modes.keys).to eq(%i[energy counter servo])
  end

  it "mode 1: you get three energy" do
    game.resolve_choice!(mode: :energy)
    game.settle!

    expect(p1.energy).to eq(3)
    expect(servos).to be_empty
    expect(counters(bears)).to eq(0)
  end

  it "mode 2: puts a +1/+1 counter on target creature" do
    game.resolve_choice!(mode: :counter)
    game.resolve_choice!(target: opp_bears)
    game.settle!

    expect(counters(opp_bears)).to eq(1)
    expect([opp_bears.power, opp_bears.toughness]).to eq([3, 3])
    expect(p1.energy).to eq(0)
    expect(servos).to be_empty
  end

  it "mode 2 can target the Inventor itself" do
    game.resolve_choice!(mode: :counter)
    game.resolve_choice!(target: inventor)
    game.settle!

    expect(counters(inventor)).to eq(1)
  end

  it "mode 3: creates a 1/1 colorless Servo artifact creature token" do
    game.resolve_choice!(mode: :servo)
    game.settle!

    expect(servos.count).to eq(1)
    servo = servos.first
    expect([servo.power, servo.toughness]).to eq([1, 1])
    expect(servo).to be_artifact
    expect(servo).to be_token
    expect(servo.colors).to be_empty
    expect(p1.energy).to eq(0)
  end

  it "rejects an unknown mode" do
    expect { game.resolve_choice!(mode: :bogus) }.to raise_error(RuntimeError, /Invalid mode/)
  end

  it "takes the first mode if the choice is skipped" do
    game.skip_choice!
    game.settle!

    expect(p1.energy).to eq(3)
    expect(game.choices).to be_empty
  end
end
