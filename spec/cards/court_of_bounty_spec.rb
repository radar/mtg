# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CourtOfBounty do
  include_context "two player game"

  let!(:court) { ResolvePermanent("Court of Bounty", owner: p1) }

  it "makes its controller the monarch when it enters" do
    expect(p1.monarch?).to be true
  end

  context "at the beginning of the controller's upkeep" do
    before do
      2.times { game.next_turn }
    end

    context "when not the monarch" do
      before { game.make_monarch!(p2) }

      it "may put a land card from hand onto the battlefield" do
        forest = Card("Forest", owner: p1)
        p1.hand.add(forest)
        go_to_upkeep!

        game.resolve_choice!
        game.resolve_choice!(target: forest)

        expect(forest.zone).to be_battlefield
      end

      it "does not offer a creature card" do
        bear = Card("Grizzly Bears", owner: p1)
        p1.hand.add(bear)
        go_to_upkeep!

        game.resolve_choice!
        choice = game.choices.last
        expect(choice.choices).not_to include(bear)
      end
    end

    context "when the monarch" do
      it "may put a creature or land card from hand onto the battlefield" do
        bear = Card("Grizzly Bears", owner: p1)
        p1.hand.add(bear)
        go_to_upkeep!

        game.resolve_choice!
        choice = game.choices.last
        expect(choice.choices).to include(bear)

        game.resolve_choice!(target: bear)
        expect(bear.zone).to be_battlefield
      end
    end
  end

  def go_to_upkeep!
    current_turn.untap!
    current_turn.upkeep!
  end
end
