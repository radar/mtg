require 'spec_helper'

RSpec.describe Magic::Cards::AnnexSentry do
  include_context "two player game"

  let(:card) { Card("Annex Sentry") }
  subject(:annex_sentry) { Card("Annex Sentry", owner: p1) }
  let(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }
  let(:loxodon_wayfarer) { ResolvePermanent("Loxodon Wayfarer", owner: p2) }

  before do
    p1.hand.add(annex_sentry)
  end

  it "has toxic 1" do
    expect(annex_sentry).to have_keyword(Magic::Cards::Keywords::Toxic)
  end

  it "exiles a target creature or artifact an opponent controls with CMC 3 or less" do
    p1.add_mana(white: 3)
    p1.cast(card: annex_sentry) do
      _1.pay_mana(generic: { white: 2 }, white: 1)
    end

    game.stack.resolve!

    choice = game.choices.last
    expect(choice).to be_a(Magic::Cards::AnnexSentry::Choice)
    game.resolve_choice!(target: wood_elves)

    permanent = game.battlefield.by_name("Annex Sentry").first

    expect(wood_elves.card.zone).to be_exile
    expect(permanent.exiled_cards).to include(wood_elves.card)

    permanent.destroy!
    # Old Permanent has gone away, so new one created by card coming back.
    new_wood_elves = game.battlefield.by_name("Wood Elves").first
    expect(new_wood_elves.zone).to be_battlefield
  end
end
