# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CemeteryRecruitment do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:bears) { Card("Grizzly Bears", owner: p1) }
  let(:ghoul) { Card("Diregraf Ghoul", owner: p1) }
  let(:bolt) { Card("Boltwave", owner: p1) }
  let(:recruitment) { Card("Cemetery Recruitment", owner: p1) }

  def cast_recruitment(target)
    p1.hand.add(recruitment)
    p1.add_mana(black: 2)
    cast_and_resolve(card: recruitment, targeting: target) { |a| a.pay_mana(black: 1, generic: { black: 1 }) }
  end

  it "returns a creature card from your graveyard to your hand without drawing for a non-Zombie" do
    p1.graveyard.add(bears)
    hand_size = p1.hand.count
    cast_recruitment(bears)

    expect(bears.zone).to be_hand
    # the spell came from and left the hand; only the creature arrived, nothing was drawn
    expect(p1.hand.count).to eq(hand_size + 1)
  end

  it "draws a card when the returned card is a Zombie" do
    p1.graveyard.add(ghoul)
    hand_size = p1.hand.count
    cast_recruitment(ghoul)

    expect(ghoul.zone).to be_hand
    expect(p1.hand.count).to eq(hand_size + 2)
  end

  it "can't target a noncreature card" do
    p1.graveyard.add(bolt)
    p1.hand.add(recruitment)

    expect { cast_action(card: recruitment, targeting: bolt) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end
end
