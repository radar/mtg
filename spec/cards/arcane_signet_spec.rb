require "spec_helper"

RSpec.describe Magic::Cards::ArcaneSignet do
  include_context "two player game"

  subject!(:signet) { ResolvePermanent("Arcane Signet", owner: p1) }

  context "when commander identity is Golgari" do
    before { p1.add_commander(Card("Lathril, Blade Of The Elves", owner: p1)) }

    it "taps for one mana of a color in the commander's color identity" do
      expect(signet.activated_abilities.first.choices).to match_array([:black, :green])

      p1.activate_ability(ability: signet.activated_abilities.first) { _1.choose(:black) }
      expect(p1.mana_pool[:black]).to eq(1)
      expect(signet).to be_tapped
    end

    it "cannot tap for a color outside the commander's color identity" do
      expect {
        p1.activate_ability(ability: signet.activated_abilities.first) { _1.choose(:red) }
      }.to raise_error(/Invalid choice made for mana ability/)
    end
  end
end
