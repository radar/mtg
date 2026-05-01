# frozen_string_literal: true
require "spec_helper"

RSpec.describe Magic::Cards::RunAfoul do
  include_context "two player game"

  subject(:run_afoul) { Card("Run Afoul") }

  context "when the targeted opponent controls a creature with flying" do
    let!(:concordia_pegasus) { ResolvePermanent("Concordia Pegasus", owner: p2) }

    it "the opponent sacrifices the flying creature" do
      p1.add_mana(green: 2)
      p1.cast(card: run_afoul) do |action|
        action.targeting(p2)
        action.pay_mana(green: 1, generic: { green: 1 })
      end
      game.stack.resolve!

      expect(concordia_pegasus.card.zone).to be_graveyard
    end

    context "and a non-flying creature" do
      let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }

      it "only the flying creature is a valid sacrifice choice" do
        p1.add_mana(green: 2)
        p1.cast(card: run_afoul) do |action|
          action.targeting(p2)
          action.pay_mana(green: 1, generic: { green: 1 })
        end
        game.stack.resolve!

        expect(concordia_pegasus.card.zone).to be_graveyard
        expect(game.battlefield.creatures).to include(wood_elves)
      end
    end
  end

  context "when the targeted opponent controls no creatures with flying" do
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }

    it "no choice is created and no creature is sacrificed" do
      p1.add_mana(green: 2)
      p1.cast(card: run_afoul) do |action|
        action.targeting(p2)
        action.pay_mana(green: 1, generic: { green: 1 })
      end
      game.stack.resolve!

      expect(game.battlefield.creatures).to include(wood_elves)
      expect(game.choices).to be_empty
    end
  end
end
