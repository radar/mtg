# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MeathookMassacreII do
  include_context "two player game"

  before { go_to_main_phase! }

  def in_play(player) = player.creatures.map(&:name)

  describe "when it enters" do
    let(:card) { Card("Meathook Massacre II", owner: p1).tap { p1.hand.add(_1) } }
    let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:mine_too) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }

    def cast(x:)
      p1.add_mana(black: 4 + 2 * x)
      p1.cast(card: card, value_for_x: x) { _1.pay_mana(black: 4, x: { black: 2 * x }) }
      game.stack.resolve!
      game.settle!
    end

    it "costs twice X plus {B}{B}{B}{B}" do
      p1.add_mana(black: 5)

      expect { p1.cast(card: card, value_for_x: 1) { _1.pay_mana(black: 4, x: { black: 1 }) } }
        .to raise_error(Magic::Costs::Mana::OutstandingBalance)
    end

    it "makes each player sacrifice X creatures of their choice" do
      cast(x: 1)

      choice = game.choices.last
      expect(choice).to be_a(Magic::Choice::SacrificeCreatures)
      expect(choice.player).to eq(p1)
      game.resolve_choice!(sacrifices: [mine])

      expect(mine.zone).to be_nil
      expect(mine_too.zone).to be_battlefield
      expect(theirs.zone).to be_nil # one creature: no choice to make
    end

    it "makes a player with fewer than X creatures sacrifice them all" do
      cast(x: 3)

      # Massacre is on the battlefield when they die, so its death triggers ask: decline them all.
      expect(game.choices.to_a).to all(be_a(described_class::OwnCreatureChoice).or(be_a(described_class::OpponentCreatureChoice)))
      game.skip_choice! while game.choices.any?
      # Declining the opponent's death trigger gives you their creature.
      expect(in_play(p1)).to eq(["Grizzly Bears"])
      expect(in_play(p2)).to be_empty
    end

    it "refuses the wrong number of sacrifices" do
      cast(x: 1)

      expect { game.resolve_choice!(sacrifices: [mine, mine_too]) }.to raise_error(ArgumentError)
    end

    it "sacrifices nothing for X = 0" do
      cast(x: 0)

      expect(in_play(p1).size).to eq(2)
      expect(game.choices).to be_empty
    end
  end

  describe "the death triggers" do
    let!(:massacre) { ResolvePermanent("Meathook Massacre II", owner: p1, value_for_x: 0) }
    let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }

    it "lets you pay 3 life to return your creature with a finality counter" do
      mine.destroy!
      game.settle!
      game.resolve_choice!

      expect(p1.life).to eq(17)
      returned = p1.permanents.find { _1.card == mine.card }
      expect(returned.counters.of_type(Magic::Counters::Finality).count).to eq(1)
    end

    it "lets you decline" do
      mine.destroy!
      game.settle!
      game.skip_choice!

      expect(p1.life).to eq(20)
      expect(mine.card.zone).to be_graveyard
    end

    it "exiles the returned creature when it dies again" do
      mine.destroy!
      game.settle!
      game.resolve_choice!
      p1.permanents.find { _1.card == mine.card }.destroy!
      game.settle!

      expect(mine.card.zone).to be_exile
    end

    it "gives an opponent's creature to you if they don't pay 3 life" do
      theirs.destroy!
      game.settle!
      choice = game.choices.last
      expect(choice.chooser).to eq(p2)
      game.skip_choice!

      expect(p2.life).to eq(20)
      returned = p1.permanents.find { _1.card == theirs.card }
      expect(returned.counters.of_type(Magic::Counters::Finality).count).to eq(1)
      expect(returned.controller).to eq(p1)
    end

    it "leaves an opponent's creature in their graveyard if they pay 3 life" do
      theirs.destroy!
      game.settle!
      game.resolve_choice!

      expect(p2.life).to eq(17)
      expect(theirs.card.zone).to be_graveyard
    end

    it "does nothing for a token dying" do
      token = Magic::Cards::MidnightMayhem::GremlinToken.new(game: game, owner: p1).resolve!
      token.destroy!
      game.settle!

      expect(game.choices).to be_empty
    end
  end
end
