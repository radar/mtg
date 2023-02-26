require 'spec_helper'

RSpec.describe Magic::Cards::TemperedVeteran do
  include_context "two player game"

  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }
  subject!(:tempered_veteran) { ResolvePermanent("Tempered Veteran", owner: p1) }

  context "first activated ability" do
    let(:ability) { tempered_veteran.activated_abilities.first }

    it "adds a counter to a creature with a counter" do
      p1.add_mana(white: 2)
      wood_elves.add_counter(Magic::Counters::Plus1Plus1)
      action = Magic::Actions::ActivateAbility.new(player: p1, permanent: tempered_veteran, ability: ability)
      action.targeting(wood_elves)
      action.pay_mana({ white: 1 })
      action.pay_tap
      action.finalize_costs!(p1)

      game.take_action(action)
      game.tick!

      expect(tempered_veteran).to be_tapped
      expect(wood_elves.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(2)
    end

    it "cannot add a counter to a creature without a counter" do
      action = Magic::Actions::ActivateAbility.new(player: p1, permanent: tempered_veteran, ability: ability)
      expect(action.valid_targets?(wood_elves)).to eq(false)
    end
  end

  context "second activated ability" do
    let(:ability) { tempered_veteran.activated_abilities[1] }

    it "adds a counter to a creature without a counter" do
      p1.add_mana(white: 6)
      action = Magic::Actions::ActivateAbility.new(player: p1, permanent: tempered_veteran, ability: ability)
      action.targeting(wood_elves)
      action.pay_mana({ generic: { white: 4 }, white: 2 })
      action.pay_tap
      action.finalize_costs!(p1)

      game.take_action(action)
      game.tick!

      expect(tempered_veteran).to be_tapped
      expect(wood_elves.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(1)
    end
  end
end
