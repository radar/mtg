require "spec_helper"

RSpec.describe Magic::Cards::LeafkinAvenger do
  include_context "two player game"

  subject(:leafkin_avenger) { ResolvePermanent("Leafkin Avenger") }

  before do
    ResolvePermanent("Epicure Of Blood") # has 4 Power
    ResolvePermanent("Wood Elves") # has 1 Power
  end

  context "first activated ability" do
    it "taps and adds 2 green" do
      # Counts itself (Leafkin Avenger) and Epicure of Blood
      ability = leafkin_avenger.activated_abilities.first
      p1.activate_ability(ability: ability)

      expect(leafkin_avenger).to be_tapped
      expect(p1.mana_pool[:green]).to eq(2)
    end
  end

  context "second activated ability" do
    let!(:basri_ket) { ResolvePermanent("Basri Ket", owner: p2) }

    it "deals damage to target player or planeswalker" do
      ability = leafkin_avenger.activated_abilities.last
      expect(ability.target_choices).to include(p1)
      expect(ability.target_choices).to include(p2)
      expect(ability.target_choices).to include(basri_ket)

      p1.add_mana(red: 8)
      p1.activate_ability(ability: ability) do
        _1.pay_mana(generic: { red: 7 }, red: 1)
        _1.targeting(p2)
      end

      expect(p2.life).to eq(16)
    end
  end

end
