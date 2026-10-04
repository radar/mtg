# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Effects::GrantCastFromGraveyard do
  def parse(text) = Magic::CardParser::Effect.parse(text)

  it "reads 'You may cast target <Type> creature card from your graveyard this turn.'" do
    effect = parse("You may cast target Zombie creature card from your graveyard this turn.")
    expect(effect).to be_a(described_class)
    expect(effect.target_choices).to eq('controller.graveyard.cards.select { _1.type?("Zombie") && _1.type?("Creature") }')
    expect(effect.resolve_call).to eq("game.play_permissions.grant_until_end_of_turn(card: target, player: controller, from_graveyard: true)")
  end

  it "reads a plain card type, and ignores other casting riders" do
    expect(parse("You may cast target creature card from your graveyard this turn.").target_choices).to include('_1.type?("Creature")')
    expect(parse("You may cast target creature card from your graveyard this turn without paying its mana cost.")).to be_nil
  end

  it "makes ReturnCards read a subtype together with a card type" do
    effect = parse("Return target Zombie creature card from your graveyard to the battlefield.")
    expect(effect.target_choices).to include('_1.type?("Zombie")', '_1.type?("Creature")')
    expect(parse("Return target Zombie card from your graveyard to the battlefield.").target_choices).to include('_1.type?("Zombie")')
  end
end
