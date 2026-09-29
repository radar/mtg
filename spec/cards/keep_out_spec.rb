# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KeepOut do
  include_context "two player game"

  let(:card) { Card("Keep Out", owner: p1) }

  def cast_mode(index, target)
    p1.hand.add(card)
    p1.add_mana(white: 2)
    p1.cast(card:) do |action|
      action.choose_mode(card.modes[index]) { |mode| mode.targeting(target) }
      action.pay_mana(generic: { white: 1 }, white: 1)
    end
    game.stack.resolve!
  end

  it "deals 4 damage to a tapped creature" do
    tapped = ResolvePermanent("Courser Of Kruphix", owner: p2)
    tapped.tap!
    cast_mode(0, tapped)

    expect(tapped.card.zone).to be_graveyard
  end

  it "cannot target an untapped creature with the damage mode" do
    untapped = ResolvePermanent("Courser Of Kruphix", owner: p2)

    expect(card.modes[0].new(game:, card:).target_choices).not_to include(untapped)
  end

  it "destroys an enchantment" do
    aura = ResolvePermanent("Clachan Festival", owner: p2)
    cast_mode(1, aura)

    expect(aura.card.zone).to be_graveyard
  end
end
