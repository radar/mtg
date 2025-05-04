require 'spec_helper'

RSpec.describe Magic::Cards::Bloodghast do
  include_context "two player game"

  context "on the battlefield" do
    let(:bloodghast) { ResolvePermanent("Bloodghast") }
    let(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }

    it "cannot block" do
      expect(bloodghast.can_block?(wood_elves)).to eq(false)
    end

    context "when an opponent has more than 10 life" do
      it "does not have haste" do
        expect(bloodghast).not_to have_keyword(:haste)
      end
    end

    context "when an opponent has less than 10 life" do

      before do
        p2.lose_life(11)
      end

      it "has haste" do
        expect(bloodghast).to have_keyword(:haste)
      end
    end
  end

  context "when in the graveyard" do
    let(:bloodghast) { Card("Bloodghast") }

    before do
      p1.graveyard.add(bloodghast)
    end

    context "landfall ability" do
      let(:land) { p1.hand.lands.first }

      it "triggers a may choice" do
        p1.play_land(land: land)

        choice = game.choices.first
        expect(choice).to be_a(Magic::Cards::Bloodghast::Choice)
        expect(choice).to be_a(Magic::Choice::May)

        game.resolve_choice!(target: bloodghast)

        battlefield_bloodghast = game.battlefield.creatures.by_name("Bloodghast").first
        expect(battlefield_bloodghast).not_to be_nil
      end
    end
  end
end
