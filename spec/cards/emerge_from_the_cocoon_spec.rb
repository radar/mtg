# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EmergeFromTheCocoon do
  include_context "two player game"

  let(:bears) { Card("Grizzly Bears", owner: p1) }

  before do
    go_to_main_phase!
    p1.graveyard.add(bears)
  end

  it "returns a creature card from your graveyard to the battlefield and gains 3 life" do
    p1.add_mana(white: 5)
    p1.cast(card: Card("Emerge From The Cocoon")) do
      _1.auto_pay_mana
      _1.targeting(bears)
    end
    game.stack.resolve!
    game.settle!

    expect(p1.creatures.map(&:card)).to include(bears)
    expect(p1.life).to eq(23)
  end
end
