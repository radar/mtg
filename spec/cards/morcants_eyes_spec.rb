# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MorcantsEyes do
  include_context "two player game"

  let(:eyes) { ResolvePermanent("Morcant's Eyes", owner: p1) }

  it "surveils 1 at the beginning of your upkeep" do
    eyes
    current_turn.untap!
    current_turn.upkeep!

    choice = game.choices.find { _1.is_a?(Magic::Choice::Surveil) }
    expect(choice).not_to be_nil
    expect(choice.amount).to eq(1)
  end

  context "sacrifice ability" do
    before { go_to_main_phase! }

    it "creates a 2/2 black and green Elf for each Elf card in your graveyard, counting itself" do
      eyes
      p1.graveyard.add(Card("Eclipsed Elf", owner: p1))
      p1.add_mana(green: 6)
      p1.activate_ability(ability: eyes.activated_abilities.first) { |a| a.pay_mana(generic: { green: 4 }, green: 2) }
      game.stack.resolve!

      expect(eyes.card.zone).to be_graveyard
      elves = p1.creatures.select { _1.name == "Elf" }
      expect(elves.count).to eq(2)
      expect(elves.first.power).to eq(2)
      expect(elves.first.colors).to contain_exactly(:black, :green)
    end

    it "can only be activated as a sorcery" do
      eyes
      go_to_main_phase_for!(p2)

      expect(eyes.activated_abilities.first.requirements_met?).to eq(false)
    end
  end
end
