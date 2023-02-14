require 'spec_helper'

RSpec.describe Magic::Cards::AnnexSentry do
  include_context "two player game"

  let(:card) { Card("Annex Sentry") }
  subject(:permanent) { Magic::Permanent.resolve(game: game, controller: p1, card: card) }

  before do
    game.battlefield.add(permanent)
  end

  it "has toxic 1" do
    expect(subject).to have_keyword(Magic::Cards::Keywords::Toxic)
  end
end
