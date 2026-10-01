# frozen_string_literal: true

require "spec_helper"
require_relative "card_parser_helpers"

# Renew: an activated ability usable from the card's owner's graveyard (Rules::Renew), plus
# putting several counter kinds at once (Effects::AddCounters), keyword counters included.
RSpec.describe "CardParser generated Renew cards in play" do
  include CardParserHelpers
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:card_class) do
    load_card(<<~TEXT)
      Test Renewer {2}{G}
      Creature — Human Warrior
      Trample
      Renew — {1}{G}, Exile this card from your graveyard: Put a +1/+1 counter and a reach counter on target creature. Activate only as a sorcery.
      4/2
    TEXT
  end
  let(:card) { card_class.new(game: game, owner: p1).tap { |c| p1.graveyard.add(c) } }
  let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "puts a +1/+1 counter and a reach counter on the target creature, exiling the card" do
    p1.add_mana(green: 2)
    p1.activate_ability(ability: card.graveyard_abilities.first) { |a| a.pay_mana(generic: { green: 1 }, green: 1).pay_self_exile.targeting(bear) }
    game.stack.resolve!
    game.tick!

    expect(card.zone).to be_exile
    expect(bear.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(1)
    expect(bear.counters.of_type(Magic::Counters::Reach).count).to eq(1)
    expect(bear).to be_reach
    expect(bear.power).to eq(3)
  end

  it "is offered by legal_actions only from the graveyard in a main phase with an empty stack" do
    card
    expect(game.legal_actions(p1).grep(Magic::Actions::ActivateAbility).map { _1.ability.source }).to include(card)
    current_turn.beginning_of_combat!
    expect(game.legal_actions(p1).grep(Magic::Actions::ActivateAbility).map { _1.ability.source }).not_to include(card)
  end

  it "cannot be activated outside a main phase" do
    p1.add_mana(green: 2)
    current_turn.beginning_of_combat!

    expect { p1.activate_ability(ability: card.graveyard_abilities.first) { |a| a.pay_mana(generic: { green: 1 }, green: 1).pay_self_exile.targeting(bear) } }
      .to raise_error(Magic::IllegalAction)
  end
end
