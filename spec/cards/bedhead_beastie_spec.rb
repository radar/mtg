# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BedheadBeastie do
  include_context "two player game"

  let(:beastie) { ResolvePermanent("Bedhead Beastie", owner: p1) }

  it "is a 5/6 with menace" do
    expect(beastie.power).to eq(5)
    expect(beastie.toughness).to eq(6)
    expect(beastie).to be_menace
  end

  it "has mountaincycling {2}" do
    card = Card("Bedhead Beastie", owner: p1)
    p1.hand.add(card)
    mountain = Card("Mountain", owner: p1)
    p1.library.add(Card("Forest", owner: p1))
    p1.library.add(mountain)
    p1.add_mana(green: 2)
    p1.cycle(card:) { _1.pay_mana(generic: { green: 2 }) }
    game.choices.last.resolve!(targets: [mountain])

    expect(card.zone).to be_graveyard
    expect(mountain.zone).to be_hand
  end
end
