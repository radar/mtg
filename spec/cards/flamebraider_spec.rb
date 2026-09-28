# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Flamebraider do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:flamebraider) { ResolvePermanent("Flamebraider", owner: p1) }

  def tap_for(mix)
    p1.activate_ability(ability: flamebraider.activated_abilities.first) { |a| a.choose(mix) }
  end

  it "adds two mana in any combination of colors, as restricted mana" do
    tap_for(%i[red blue])

    expect(p1.restricted_mana.map(&:color)).to contain_exactly(:red, :blue)
    expect(p1.mana_pool.values.sum).to eq(0)
  end

  it "allows two of the same color" do
    tap_for(:green)

    expect(p1.restricted_mana.map(&:color)).to eq(%i[green green])
  end

  it "rejects a combination that is not two mana" do
    expect { tap_for(%i[red]) }.to raise_error(ArgumentError)
  end

  it "pays for an Elemental spell" do
    tap_for(%i[green green])
    spell = Card("Luminollusk", owner: p1)
    p1.hand.add(spell)
    action = Magic::Actions::Cast.new(card: spell, player: p1, game: game)
    expect(action.mana_cost.can_pay?(p1)).to eq(false) # {3}{G} needs 4, only 2 restricted

    p1.add_mana(green: 2)
    expect(action.mana_cost.can_pay?(p1)).to eq(true)
  end

  it "cannot pay for a non-Elemental spell" do
    tap_for(%i[green green])
    bears = Card("Grizzly Bears", owner: p1)
    p1.hand.add(bears)
    action = Magic::Actions::Cast.new(card: bears, player: p1, game: game)

    expect(action.mana_cost.can_pay?(p1)).to eq(false)
  end

  it "spends the restricted mana on an Elemental spell" do
    tap_for(%i[green red])
    spell = Card("Explosive Prodigy", owner: p1)
    p1.hand.add(spell)
    p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 1 }, red: 1) }

    expect(p1.restricted_mana).to be_empty
  end
end
