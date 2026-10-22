# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VoltstormAngel do
  include_context "two player game"

  let!(:angel) { ResolvePermanent("Voltstorm Angel", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:enemy) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def end_turn!
    current_turn.end!
    current_turn.cleanup!
    game.settle!
  end

  it "is a 4/4 flying Angel" do
    expect([angel.power, angel.toughness]).to eq([4, 4])
    expect(angel).to be_flying
    expect(angel.type?("Angel")).to be(true)
  end

  it "gives you three energy when it enters" do
    expect(p1.energy).to eq(3)
  end

  context "at the beginning of combat on your turn" do
    it "offers to pay {E}{E}" do
      skip_to_combat!

      expect(game.choices.first).to be_a(Magic::Choice::PayEnergy)
      expect(game.choices.first.amount).to eq(2)
    end

    it "gives vigilance and lifelink until end of turn with the first mode" do
      skip_to_combat!
      game.resolve_choice!
      game.resolve_choice!(mode: :keywords)
      game.settle!

      expect(p1.energy).to eq(1)
      expect(angel).to be_vigilant
      expect(angel).to be_lifelink
      expect(bears.power).to eq(2)

      end_turn!
      expect(angel).not_to be_vigilant
      expect(angel).not_to be_lifelink
    end

    it "gives other creatures you control +1/+1 until end of turn with the second mode" do
      skip_to_combat!
      game.resolve_choice!
      game.resolve_choice!(mode: :pump)
      game.settle!

      expect([bears.power, bears.toughness]).to eq([3, 3])
      expect([angel.power, angel.toughness]).to eq([4, 4])
      expect([enemy.power, enemy.toughness]).to eq([2, 2])
      expect(angel).not_to be_vigilant

      end_turn!
      expect([bears.power, bears.toughness]).to eq([2, 2])
    end

    it "takes the first mode when the mode choice is skipped" do
      skip_to_combat!
      game.resolve_choice!
      game.skip_choice!
      game.settle!

      expect(p1.energy).to eq(1)
      expect(angel).to be_vigilant
      expect(angel).to be_lifelink
    end

    it "does nothing when you decline to pay" do
      skip_to_combat!
      game.skip_choice!
      game.settle!

      expect(p1.energy).to eq(3)
      expect(game.choices).to be_empty
      expect(angel).not_to be_vigilant
    end

    it "offers nothing with less than two energy" do
      p1.pay_energy!(2)
      skip_to_combat!

      expect(game.choices).to be_empty
    end

    it "doesn't trigger at the beginning of the opponent's combat" do
      go_to_main_phase_for!(p2)
      current_turn.beginning_of_combat!

      expect(game.choices).to be_empty
    end
  end
end
