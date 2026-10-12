# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ReluctantRoleModel do
  include_context "two player game"

  let!(:model) { ResolvePermanent("Reluctant Role Model", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "is a 2/2" do
    expect(model.power).to eq(2)
    expect(model.toughness).to eq(2)
  end

  describe "Survival" do
    before { go_to_main_phase! }

    def to_second_main!
      current_turn.beginning_of_combat!
      current_turn.declare_attackers!
      current_turn.end_of_combat!
      current_turn.second_main!
      game.settle!
    end

    it "does nothing when untapped" do
      to_second_main!
      expect(game.choices).to be_empty
    end

    it "offers a flying, lifelink or +1/+1 counter when tapped" do
      model.tap!
      to_second_main!
      game.resolve_choice!(mode: :lifelink)
      game.settle!

      expect(model.counters.of_type(Magic::Counters::Lifelink).count).to eq(1)
      expect(model).to be_lifelink
    end
  end

  describe "when a creature with counters dies" do
    it "moves its counters to up to one target creature" do
      bears.put_counters!("+1/+1", amount: 2)
      game.tick!
      bears.destroy!
      game.settle!
      game.resolve_choice!(target: model)
      game.settle!

      expect(model.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(2)
    end

    it "does not trigger for a creature without counters" do
      bears.destroy!
      game.settle!

      expect(game.choices).to be_empty
    end

    it "triggers when Reluctant Role Model itself dies" do
      model.put_counters!("+1/+1", amount: 1)
      model.destroy!
      game.settle!
      game.resolve_choice!(target: bears)
      game.settle!

      expect(bears.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(1)
    end
  end
end
