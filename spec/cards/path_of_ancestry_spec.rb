# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PathOfAncestry do
  include_context "two player game"

  subject(:path) { ResolvePermanent("Path Of Ancestry", owner: p1) }

  before { p1.add_commander(Card("Lathril, Blade Of The Elves", owner: p1)) }

  it "enters tapped" do
    expect(Card("Path Of Ancestry", owner: p1).enters_tapped?).to be true
  end

  it "offers the colors in your commander's color identity" do
    expect(path.activated_abilities.first.choices).to match_array(%i[black green])
  end

  it "adds one mana of a color in your commander's color identity" do
    path.untap!
    p1.activate_ability(ability: path.activated_abilities.first) { _1.choose(:green) }

    expect(p1.mana_pool[:green]).to eq(1)
  end

  it "can't make a color outside your commander's color identity" do
    path.untap!
    expect {
      p1.activate_ability(ability: path.activated_abilities.first) { _1.choose(:red) }
    }.to raise_error(/Invalid choice made for mana ability/)
  end
end
