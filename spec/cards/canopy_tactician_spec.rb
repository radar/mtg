require 'spec_helper'

RSpec.describe Magic::Cards::CanopyTactician do
  include_context "two player game"

  let!(:lathril) { ResolvePermanent("Lathril, Blade Of The Elves", owner: p1) }
  subject! { ResolvePermanent("Canopy Tactician", owner: p1) }

  before do
    game.tick!
  end

  context "static ability" do
    it "gives lathril +1/+1" do
      expect(lathril.power).to eq(3)
      expect(lathril.toughness).to eq(4)
    end

    it "does not give itself the boost", aggregate_failures: true do
      expect(subject.power).to eq(3)
      expect(subject.toughness).to eq(3)
    end
  end

  context "mana ability" do
    def activate_ability
      p1.activate_ability(ability: subject.activated_abilities.first)
    end

    it "adds 3 green mana" do
      activate_ability
      expect(p1.mana_pool[:green]).to eq(3)
    end
  end
end
