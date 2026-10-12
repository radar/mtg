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

    expect(p1.restricted_mana.map(&:color)).to eq([:green])
  end

  context "when its mana is spent on a creature spell" do
    before do
      go_to_main_phase!
      path.untap!
      p1.activate_ability(ability: path.activated_abilities.first) { _1.choose(:green) }
    end

    it "scries 1 if the spell shares a creature type with your commander" do
      elf = Card("Elvish Mystic", owner: p1)
      p1.hand.add(elf)
      p1.cast(card: elf) { |a| a.pay_mana(green: 1) }

      expect(game.choices.last).to be_a(Magic::Choice::Scry)
    end

    it "does not scry for a creature that shares no type with it" do
      bears = Card("Grizzly Bears", owner: p1)
      p1.add_mana(green: 1)
      p1.hand.add(bears)
      p1.cast(card: bears) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }

      expect(game.choices).to be_empty
    end
  end

  it "can't make a color outside your commander's color identity" do
    path.untap!
    expect {
      p1.activate_ability(ability: path.activated_abilities.first) { _1.choose(:red) }
    }.to raise_error(/Invalid choice made for mana ability/)
  end
end
