require "spec_helper"

RSpec.describe Magic::Cards::FortifiedVillage do
  include_context "two player game"
  before { go_to_main_phase! }

  context "without a Forest or Plains in hand" do
    before { p1.hand.items.clear }

    it "enters tapped, with no choice" do
      village = play_land(Card("Fortified Village"))

      expect(village).to be_tapped
      expect(game.choices).to be_empty
    end
  end

  context "with a Forest in hand" do
    let(:forest) { Card("Forest", owner: p1) }

    before do
      p1.hand.items.clear
      p1.hand.add(forest)
    end

    it "offers a may choice to reveal" do
      village = play_land(Card("Fortified Village"))

      expect(game.choices.last).to be_a(Magic::Cards::FortifiedVillage::MayRevealChoice)
      expect(village).to be_tapped
    end

    it "enters tapped when declining to reveal" do
      village = play_land(Card("Fortified Village"))
      game.skip_choice!

      expect(village).to be_tapped
    end

    it "enters untapped when revealing the Forest" do
      village = play_land(Card("Fortified Village"))
      game.resolve_choice!
      game.resolve_choice!(target: forest)

      expect(village).not_to be_tapped
    end
  end

  context "with a Plains in hand" do
    let(:plains) { Card("Plains", owner: p1) }

    before do
      p1.hand.items.clear
      p1.hand.add(plains)
    end

    it "enters untapped when revealing the Plains" do
      village = play_land(Card("Fortified Village"))
      game.resolve_choice!
      game.resolve_choice!(target: plains)

      expect(village).not_to be_tapped
    end
  end

  private

  def play_land(card)
    p1.play_land(land: card)
    game.settle!
    p1.permanents.by_name(card.name).first
  end
end
