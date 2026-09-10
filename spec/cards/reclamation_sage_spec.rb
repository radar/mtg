# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ReclamationSage do
  include_context "two player game"

  it "is a 2/1 Elf Shaman" do
    sage = ResolvePermanent("Reclamation Sage", owner: p1)
    expect(sage.power).to eq(2)
    expect(sage.toughness).to eq(1)
    expect(sage.card.types).to include("Elf")
    expect(sage.card.types).to include("Shaman")
  end

  context "when entering the battlefield" do
    it "presents a may choice to destroy target artifact or enchantment" do
      sage = ResolvePermanent("Reclamation Sage", owner: p1)
      expect(game.choices.last).to be_a(described_class::MayDestroyChoice)
      expect(game.choices.last.actor).to eq(sage)
    end

    context "when accepting" do
      let!(:mind_stone) { ResolvePermanent("Mind Stone", owner: p2) }

      before { ResolvePermanent("Reclamation Sage", owner: p1) }

      it "presents artifacts and enchantments as targets" do
        game.resolve_choice!
        choice = game.choices.last
        expect(choice).to be_a(described_class::DestroyChoice)
        expect(choice.choices).to include(mind_stone)
      end

      it "destroys the chosen target" do
        game.resolve_choice!
        game.resolve_choice!(target: mind_stone)
        expect(mind_stone.card.zone).to be_graveyard
      end
    end

    context "when declining" do
      before { ResolvePermanent("Reclamation Sage", owner: p1) }

      it "does not destroy anything" do
        game.skip_choice!
        expect(game.choices).to be_empty
      end
    end
  end
end
