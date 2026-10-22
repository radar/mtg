# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Electrozoa do
  include_context "two player game"

  let!(:zoa) { ResolvePermanent("Electrozoa", owner: p1) }

  it "is a 3/1 flash flying Jellyfish" do
    expect([zoa.power, zoa.toughness]).to eq([3, 1])
    expect(zoa.has_keyword?(:flash)).to be(true)
    expect(zoa.has_keyword?(:flying)).to be(true)
    expect(zoa.type?("Jellyfish")).to be(true)
  end

  it "gives you two energy when it enters" do
    expect(p1.energy).to eq(2)
  end

  context "at the beginning of your first main phase" do
    before { go_to_main_phase! }

    it "lets you pay {E} to keep it untapped" do
      game.resolve_choice!
      game.settle!

      expect(p1.energy).to eq(1)
      expect(zoa).not_to be_tapped
    end

    it "taps it when you decline" do
      game.skip_choice!
      game.settle!

      expect(p1.energy).to eq(2)
      expect(zoa).to be_tapped
    end
  end

  it "taps it without a choice when you have no energy" do
    p1.pay_energy!(2)
    go_to_main_phase!
    game.settle!

    expect(game.choices).to be_empty
    expect(zoa).to be_tapped
  end

  it "doesn't trigger on an opponent's first main phase" do
    go_to_main_phase_for!(p2)
    game.settle!

    expect(game.choices).to be_empty
    expect(p1.energy).to eq(2)
    expect(zoa).not_to be_tapped
  end
end
