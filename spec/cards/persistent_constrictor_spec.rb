# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PersistentConstrictor do
  include_context "two player game"

  let!(:constrictor) { ResolvePermanent("Persistent Constrictor", owner: p1) }

  def snake = p1.creatures.find { _1.name == "Persistent Constrictor" }

  describe "the upkeep trigger" do
    it "drains the opponent and puts a -1/-1 counter on their creature" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      ResolvePermanent("Grizzly Bears", owner: p2)
      game.next_turn
      current_turn.untap!
      current_turn.upkeep!
      game.settle!
      game.resolve_choice!(target: bears)
      game.settle!

      expect(p2.life).to eq(19)
      expect(bears.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(1)
    end

    it "doesn't trigger on its controller's upkeep" do
      current_turn.untap!
      current_turn.upkeep!
      game.settle!

      expect(p2.life).to eq(20)
    end

    it "still drains when the opponent has no creatures" do
      game.next_turn
      current_turn.untap!
      current_turn.upkeep!
      game.settle!

      expect(p2.life).to eq(19)
    end
  end

  describe "persist" do
    it "returns with a -1/-1 counter the first time it dies" do
      constrictor.destroy!
      game.settle!

      expect(snake.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(1)
      expect([snake.power, snake.toughness]).to eq([4, 2])
    end

    it "doesn't return when it already has a -1/-1 counter" do
      constrictor.destroy!
      game.settle!
      snake.destroy!
      game.settle!

      expect(snake).to be_nil
    end
  end
end
