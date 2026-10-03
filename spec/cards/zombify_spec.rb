# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Zombify do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:bears) { Card("Grizzly Bears", owner: p1) }
  let(:bolt) { Card("Boltwave", owner: p1) }
  let(:zombify) { Card("Zombify", owner: p1) }

  def cast_zombify(target)
    p1.hand.add(zombify)
    p1.add_mana(black: 4)
    cast_and_resolve(card: zombify, targeting: target) { |a| a.pay_mana(black: 1, generic: { black: 3 }) }
  end

  it "returns a creature card from your graveyard to the battlefield" do
    p1.graveyard.add(bears)
    cast_zombify(bears)

    expect(p1.creatures.map(&:card)).to include(bears)
    expect(p1.graveyard.cards).not_to include(bears)
    expect(zombify.zone).to be_graveyard
  end

  it "can't target a noncreature card in your graveyard" do
    p1.graveyard.add(bolt)
    p1.hand.add(zombify)

    expect { cast_action(card: zombify, targeting: bolt) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "can't target a creature card in an opponent's graveyard" do
    theirs = Card("Grizzly Bears", owner: p2)
    p2.graveyard.add(theirs)
    p1.hand.add(zombify)

    expect { cast_action(card: zombify, targeting: theirs) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end
end
