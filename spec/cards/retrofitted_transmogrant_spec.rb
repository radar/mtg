# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RetrofittedTransmogrant do
  include_context "two player game"

  let(:card) { Card("Retrofitted Transmogrant", owner: p1).tap { p1.graveyard.add(_1) } }

  def activate!(player: p1, ability: card.graveyard_abilities.first)
    player.add_mana(black: 4)
    player.activate_ability(ability: ability) { _1.pay_mana(generic: { black: 3 }, black: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "is a 1/1 artifact Zombie creature" do
    permanent = ResolvePermanent("Retrofitted Transmogrant", owner: p1)

    expect([permanent.power, permanent.toughness]).to eq([1, 1])
    expect(permanent).to be_a(Magic::Permanents::Creature)
    expect(permanent.types.map(&:to_s)).to include(/Artifact/)
  end

  it "returns from the graveyard tapped with two +1/+1 counters" do
    card
    activate!

    expect(card.zone).to be_battlefield
    permanent = p1.permanents.find { _1.card == card }
    expect(permanent).to be_tapped
    expect([permanent.power, permanent.toughness]).to eq([3, 3])
  end

  it "can be activated at instant speed" do
    card
    go_to_main_phase!
    game.next_turn
    activate!

    expect(card.zone).to be_battlefield
  end

  it "can't be activated without enough mana" do
    card
    p1.add_mana(black: 2)

    expect do
      p1.activate_ability(ability: card.graveyard_abilities.first) { _1.pay_mana(generic: { black: 1 }, black: 1) }
    end.to raise_error(Magic::Costs::Mana::CannotPay)
    expect(card.zone).to be_graveyard
  end

  it "isn't offered in the opponent's legal actions" do
    card
    abilities = game.legal_actions(p2).compact.filter_map { _1.respond_to?(:ability) ? _1.ability : nil }

    expect(abilities.map(&:source)).not_to include(card)
  end
end
