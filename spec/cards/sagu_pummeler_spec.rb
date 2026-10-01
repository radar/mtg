# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SaguPummeler do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Sagu Pummeler", owner: p1) }

  it "is a 4/4 Beast with reach" do
    permanent = ResolvePermanent("Sagu Pummeler", owner: p1)

    expect([permanent.power, permanent.toughness]).to eq([4, 4])
    expect(permanent).to be_reach
  end

  it "renews for {4}{G}: two +1/+1 counters and a reach counter on target creature" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.graveyard.add(card)
    p1.add_mana(green: 5)

    p1.activate_ability(ability: card.graveyard_abilities.first) { |a| a.pay_mana(generic: { green: 4 }, green: 1).targeting(bear) }
    game.stack.resolve!
    game.tick!

    expect(card.zone).to be_exile
    expect(bear.power).to eq(4)
    expect(bear.toughness).to eq(4)
    expect(bear).to be_reach
  end

  it "can only be renewed at sorcery speed" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.graveyard.add(card)
    p1.add_mana(green: 5)
    current_turn.beginning_of_combat!

    expect { p1.activate_ability(ability: card.graveyard_abilities.first) { |a| a.pay_mana(generic: { green: 4 }, green: 1).targeting(bear) } }
      .to raise_error(Magic::IllegalAction)
  end
end
