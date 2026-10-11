# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EnchantersBane do
  include_context "two player game"

  let!(:bane) { ResolvePermanent("Enchanters Bane", owner: p1) }
  let!(:target) { ResolvePermanent("Sanctum Of Calm Waters", owner: p2) } # mana value 4

  before do
    go_to_main_phase!
    current_turn.end!
    game.settle!
  end

  it "deals damage equal to the enchantment's mana value to its controller if they decline to sacrifice" do
    game.resolve_choice!(target: target)
    game.skip_choice!
    game.settle!

    expect(p2.life).to eq(16)
    expect(target.zone).to be_battlefield
  end

  it "has the controller sacrifice it instead when they choose to" do
    game.resolve_choice!(target: target)
    game.resolve_choice!
    game.settle!

    expect(p2.life).to eq(20)
    expect(target.zone).to be_nil
  end

  it "can target an enchantment you control, itself included" do
    expect(game.choices.last.choices).to contain_exactly(bane, target)
  end

  it "doesn't trigger at the opponent's end step" do
    game.skip_choice! while game.choices.any?
    go_to_main_phase_for!(p2)
    current_turn.end!
    game.settle!

    expect(game.choices.to_a.grep(described_class::TargetChoice)).to be_empty
  end
end
