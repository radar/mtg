require 'spec_helper'

RSpec.describe Magic::Cards::EssenceWarden do
  let(:game) { Magic::Game.new }
  let(:p1) { Magic::Player.new(game: game) }

  let(:card) { described_class.new(game: game, controller: p1) }

  context "when other creature is controlled by same controller" do
    let(:loxodon_wayfarer) { Magic::Cards::LoxodonWayfarer.new(game: game, controller: p1) }

    it "adds a life to controller's life total" do
      starting_life = p1.life
      card.draw!
      card.cast!
      game.stack.resolve!
      loxodon_wayfarer.cast!
      game.stack.resolve!
      expect(p1.life).to eq(starting_life + 1)
    end
  end

  context "when other creature is controlled by another player" do
    let(:p2) { Magic::Player.new(game: game) }
    let(:loxodon_wayfarer) { Magic::Cards::LoxodonWayfarer.new(game: game, controller: p2) }

    it "adds a life to controller's life total" do
      starting_life = p1.life
      card.draw!
      card.cast!
      game.stack.resolve!
      loxodon_wayfarer.cast!
      game.stack.resolve!
      expect(p1.life).to eq(starting_life + 1)
    end
  end
end
