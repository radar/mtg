require 'spec_helper'

RSpec.describe Magic::Cards::IdolOfEndurance do
  include_context "two player game"

  let(:wood_elves) { Card("Wood Elves") }
  subject(:idol_of_endurance) { Permanent("Idol Of Endurance", owner: p1) }

  before do
    p1.graveyard.add(wood_elves)
    game.battlefield.add(subject)
  end

  context "when it enters the battlefield" do
    it "exiles all creature cards with mana cost 3 or less from graveyard" do
      subject.entered_the_battlefield!
      expect(wood_elves.zone).to be_exile
      expect(idol_of_endurance.exiled_cards).to include(wood_elves)
    end
  end

  context "when it has an exiled card" do
    before do
      game.exile.add(wood_elves)
      idol_of_endurance.exiled_cards << wood_elves
    end

    it "can play that card without incurring mana cost" do

      p1.add_mana(white: 2)
      action = Magic::Actions::ActivateAbility.new(player: p1, permanent: idol_of_endurance, ability: idol_of_endurance.activated_abilities.first)
      action.pay_mana({ generic: { white: 1 }, white: 1 })
      action.pay_tap
      action.finalize_costs!(p1)
      action.targeting(wood_elves)
      game.take_action(action)
      game.tick!

      expect(idol_of_endurance).to be_tapped

      expect(game.battlefield.controlled_by(p1).by_name("Wood Elves").count).to eq(1)
      expect(game.exile.cards.count).to eq(0)
      expect(idol_of_endurance.exiled_cards).to be_empty
    end

    it "when card leaves the battlefield, all exiled cards return to graveyard" do
      idol_of_endurance.destroy!
      expect(wood_elves.zone).to be_graveyard
    end
  end
end
