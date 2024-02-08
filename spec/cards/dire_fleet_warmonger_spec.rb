require "spec_helper"

RSpec.describe Magic::Cards::DireFleetWarmonger do
  include_context "two player game"

  let!(:permanent) { ResolvePermanent("Dire Fleet Warmonger") }
  let!(:wood_elves) { ResolvePermanent("Wood Elves") }

  context "beginning of combat, may sacrifice another creature" do
    before do
      skip_to_combat!
    end

    it "is offered a choice" do
      choice = game.choices.last
      expect(choice).to be_a(described_class::Choice)
      expect(choice.target_choices).to eq([wood_elves])

      game.resolve_choice!(choice: wood_elves)

      expect(wood_elves.card.zone).to be_graveyard

      expect(permanent.power).to eq(5)
      expect(permanent.toughness).to eq(5)
      expect(permanent.trample?).to eq(true)
    end
  end
end
