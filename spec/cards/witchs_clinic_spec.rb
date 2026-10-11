# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WitchsClinic do
  include_context "two player game"

  let!(:clinic) { ResolvePermanent("Witchs Clinic", owner: p1) }

  it "taps for {C}" do
    p1.activate_ability(ability: clinic.activated_abilities.first)

    expect(p1.mana_pool[:colorless]).to eq(1)
  end

  it "only targets commanders" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    card = Card("Grizzly Bears", owner: p1)
    p1.add_commander(card)
    commander = Magic::Permanent.resolve_spell(game: game, card: card)

    choices = clinic.activated_abilities.last.target_choices
    expect(choices).to eq([commander])
    expect(choices).not_to include(bears)
  end

  it "gives target commander lifelink until end of turn" do
    card = Card("Grizzly Bears", owner: p1)
    p1.add_commander(card)
    permanent = Magic::Permanent.resolve_spell(game: game, card: card)
    p1.add_mana(green: 2)
    p1.activate_ability(ability: clinic.activated_abilities.last) do |action|
      action.pay_mana(generic: { green: 2 })
      action.targeting(permanent)
    end
    game.stack.resolve!

    expect(permanent).to have_keyword(:lifelink)
    permanent.cleanup!
    expect(permanent).not_to have_keyword(:lifelink)
  end
end
