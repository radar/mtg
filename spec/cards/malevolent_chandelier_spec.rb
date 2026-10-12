# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MalevolentChandelier do
  include_context "two player game"

  subject(:chandelier) { ResolvePermanent("Malevolent Chandelier", owner: p1) }

  let(:ability) { chandelier.activated_abilities.first }

  def activate_on(card)
    p1.add_mana(green: 2)
    p1.activate_ability(ability: ability) do
      _1.pay_mana(generic: { green: 2 })
      _1.targeting(card)
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a 4/4 flying artifact Construct" do
    expect([chandelier.power, chandelier.toughness]).to eq([4, 4])
    expect(chandelier.artifact?).to be true
    expect(chandelier.has_keyword?(Magic::Cards::Keywords::FLYING)).to be true
  end

  context "at sorcery speed" do
    before { go_to_main_phase! }

    it "puts a card from your graveyard on the bottom of your library" do
      bears = Card("Grizzly Bears", owner: p1)
      p1.graveyard.add(bears)
      activate_on(bears)

      expect(p1.graveyard.cards).not_to include(bears)
      expect(p1.library.cards.last).to eq(bears)
    end

    it "puts a card from an opponent's graveyard on the bottom of its owner's library" do
      bolt = Card("Lightning Bolt", owner: p2)
      p2.graveyard.add(bolt)
      activate_on(bolt)

      expect(p2.graveyard.cards).not_to include(bolt)
      expect(p2.library.cards.last).to eq(bolt)
    end
  end

  it "can't be activated at instant speed" do
    chandelier
    bears = Card("Grizzly Bears", owner: p1)
    p1.graveyard.add(bears)
    expect { activate_on(bears) }.to raise_error(Magic::IllegalAction)
  end
end
