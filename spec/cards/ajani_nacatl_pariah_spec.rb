# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AjaniNacatlPariah do
  include_context "two player game"

  before { go_to_main_phase! }

  def cats(player = p1) = game.battlefield.controlled_by(player).creatures.select { _1.type?("Cat") }

  it "creates a Cat Warrior token when it enters" do
    ResolvePermanent("Ajani, Nacatl Pariah", owner: p1)
    game.settle!
    expect(cats.map(&:name)).to include("Cat Warrior")
  end

  context "when another Cat dies" do
    let!(:ajani) { ResolvePermanent("Ajani, Nacatl Pariah", owner: p1) }

    before { game.settle! }

    it "may exile Ajani and return him as a planeswalker" do
      cats.find { _1.name == "Cat Warrior" }.destroy!
      game.settle!
      game.resolve_choice!
      game.settle!

      walker = game.battlefield.controlled_by(p1).find { _1.name == "Ajani, Nacatl Avenger" }
      expect(walker).to be_planeswalker
      expect(walker.loyalty).to eq(3)
    end

    it "triggers once when several Cats die together" do
      collector = ResolvePermanent("Cat Collector", owner: p1)
      game.settle!
      cats.find { _1.name == "Cat Warrior" }.destroy!
      collector.destroy!
      game.settle!

      expect(game.choices.size).to eq(1)
      game.skip_choice!
      game.settle!
      expect(game.choices).to be_empty
    end

    it "does nothing if Ajani left the battlefield with the Cat" do
      cats.find { _1.name == "Cat Warrior" }.destroy!
      ajani.destroy!
      game.settle!

      expect(game.choices).to be_empty
      expect(game.battlefield.controlled_by(p1).map(&:name)).not_to include("Ajani, Nacatl Avenger")
    end

    it "stays a creature when the player declines" do
      cats.find { _1.name == "Cat Warrior" }.destroy!
      game.settle!
      game.skip_choice!
      expect(game.battlefield.controlled_by(p1).map(&:name)).to include("Ajani, Nacatl Pariah")
    end
  end

  context "as a planeswalker" do
    let!(:ajani) do
      ResolvePermanent("Ajani, Nacatl Pariah", owner: p1)
      game.settle!
      cats.find { _1.name == "Cat Warrior" }.destroy!
      game.settle!
      game.resolve_choice!
      game.settle!
      game.battlefield.controlled_by(p1).find { _1.name == "Ajani, Nacatl Avenger" }
    end

    def activate(index, &block)
      p1.activate_loyalty_ability(ability: ajani.loyalty_abilities[index], &block)
      game.stack.resolve!
      game.settle!
    end

    it "+2 puts a +1/+1 counter on each Cat" do
      cat = ResolvePermanent("Ajani, Nacatl Pariah", owner: p1)
      game.settle!
      activate(0)
      expect(ajani.loyalty).to eq(5)
      expect(cat.power).to eq(2)
    end

    it "0 creates a Cat Warrior token" do
      before_count = cats.count
      activate(1)
      expect(cats.count).to eq(before_count + 1)
      expect(ajani.loyalty).to eq(3)
    end

    it "0 deals damage equal to your creature count when you control another red permanent" do
      ResolvePermanent("Raging Goblin", owner: p1)
      game.settle!
      activate(1)

      expect { game.resolve_choice!(target: p2) }.to change { p2.life }.by(-cats.count - 1)
    end

    it "0 offers no damage without another red permanent" do
      activate(1)

      expect(game.choices).to be_empty
    end

    it "-4 makes the opponent keep one permanent of each type" do
      ajani.change_loyalty!(1)
      ResolvePermanent("Grizzly Bears", owner: p2)
      bears = ResolvePermanent("Serra Angel", owner: p2)
      activate(2)
      game.resolve_choice!(target: bears) while game.choices.any?
      expect(game.battlefield.controlled_by(p2).creatures).to eq([bears])
    end
  end
end
