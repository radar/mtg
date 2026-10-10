# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DemonicCounsel do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:counsel) { Card("Demonic Counsel", owner: p1) }
  let(:demon) { Card("Rune Scarred Demon", owner: p1) }
  let(:bears) { Card("Grizzly Bears", owner: p1) }

  before do
    p1.hand.add(counsel)
    p1.add_mana(black: 2)
    p1.library.add(bears)
    p1.library.add(demon)
  end

  def cast!
    cast_and_resolve(card: counsel, player: p1) { |a| a.pay_mana(generic: { black: 1 }, black: 1) }
  end

  it "searches for a Demon card and puts it into your hand" do
    cast!

    expect(game.choices.first.choices).to eq([demon])
    game.resolve_choice!(targets: [demon])

    expect(p1.hand.cards).to include(demon)
    expect(p1.library.cards).not_to include(demon)
  end

  it "can't find a non-Demon card without delirium" do
    cast!

    expect(game.choices.first.choices).not_to include(bears)
  end

  it "searches for any card with delirium" do
    [Card("Grizzly Bears", owner: p1), Card("Island", owner: p1), Card("Lightning Bolt", owner: p1),
     Card("Mind Rot", owner: p1)].each(&:move_to_graveyard!)
    expect(p1.graveyard).to be_delirium
    cast!

    expect(game.choices.first.choices).to include(bears, demon)
    game.resolve_choice!(targets: [bears])

    expect(p1.hand.cards).to include(bears)
  end
end
