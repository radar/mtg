# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GenkuFutureShaper do
  include_context "two player game"

  let!(:genku) { ResolvePermanent("Genku, Future Shaper", owner: p1) }

  def tokens = p1.creatures.select(&:token?)

  def lose_permanent(owner: p1)
    ResolvePermanent("Grizzly Bears", owner: owner).tap do |bears|
      bears.destroy!
      game.settle!
    end
  end

  it "is a legendary 2/5 Moonfolk Wizard" do
    expect([genku.power, genku.toughness]).to eq([2, 5])
    expect(genku.card).to be_legendary
    expect(genku.type?("Moonfolk")).to be(true)
  end

  context "when another nontoken permanent you control leaves the battlefield" do
    it "offers all three tokens and creates a 2/2 white Fox with vigilance" do
      lose_permanent

      expect(game.choices.first.choices).to contain_exactly(:fox, :moonfolk, :rat)
      game.resolve_choice!(mode: :fox)
      game.settle!

      fox = tokens.first
      expect([fox.power, fox.toughness]).to eq([2, 2])
      expect(fox.type?("Fox")).to be(true)
      expect(fox).to have_keyword(:vigilance)
    end

    it "creates a 1/2 blue Moonfolk with flying" do
      lose_permanent
      game.resolve_choice!(mode: :moonfolk)
      game.settle!

      token = tokens.first
      expect([token.power, token.toughness]).to eq([1, 2])
      expect(token).to have_keyword(:flying)
    end

    it "creates a 1/1 black Rat with lifelink" do
      lose_permanent
      game.resolve_choice!(mode: :rat)
      game.settle!

      token = tokens.first
      expect([token.power, token.toughness]).to eq([1, 1])
      expect(token).to have_keyword(:lifelink)
    end

    it "can't choose the same one twice in a turn, and offers none after all three" do
      lose_permanent
      game.resolve_choice!(mode: :fox)
      game.settle!
      lose_permanent

      expect(game.choices.first.choices).to contain_exactly(:moonfolk, :rat)
      game.resolve_choice!(mode: :moonfolk)
      game.settle!
      lose_permanent
      game.resolve_choice!(mode: :rat)
      game.settle!
      lose_permanent

      expect(game.choices).to be_empty
      expect(tokens.size).to eq(3)
    end

    it "resets on a new turn" do
      lose_permanent
      game.resolve_choice!(mode: :fox)
      game.settle!
      current_turn.end!
      current_turn.cleanup!
      lose_permanent

      expect(game.choices.first.choices).to contain_exactly(:fox, :moonfolk, :rat)
    end

    it "does not trigger for a token leaving" do
      lose_permanent
      game.resolve_choice!(mode: :fox)
      game.settle!
      tokens.first.destroy!
      game.settle!

      expect(game.choices).to be_empty
    end

    it "does not trigger for an opponent's permanent" do
      lose_permanent(owner: p2)

      expect(game.choices).to be_empty
      expect(tokens).to be_empty
    end

    it "does not trigger for Genku itself" do
      genku.destroy!
      game.settle!

      expect(game.choices).to be_empty
    end
  end

  context "{3}{W}{U}: Put a +1/+1 counter on each creature you control" do
    it "adds a counter to each of your creatures and none of the opponent's" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      p1.add_mana(white: 1, blue: 1, green: 3)
      p1.activate_ability(ability: genku.activated_abilities.first) do |a|
        a.pay_mana(generic: { green: 3 }, white: 1, blue: 1)
      end
      game.stack.resolve!
      game.settle!

      expect([genku.power, genku.toughness]).to eq([3, 6])
      expect([bears.power, bears.toughness]).to eq([3, 3])
      expect([theirs.power, theirs.toughness]).to eq([2, 2])
    end
  end
end
