require "spec_helper"

RSpec.describe Magic::Cards::CourserOfKruphix do
  include_context "two player game"

  it "gains life when a land enters under your control" do
    ResolvePermanent("Courser of Kruphix", owner: p1)
    ResolvePermanent("Forest", owner: p1)

    expect(p1.life).to eq(21)
  end

  describe "top of the library" do
    before { go_to_main_phase! }

    it "lets its controller play a land from the top of their library" do
      ResolvePermanent("Courser of Kruphix", owner: p1)
      top_land = Card("Forest", owner: p1)
      p1.library.add(top_land, 0)

      expect { p1.play_land(land: top_land) }.to change { p1.lands.count }.by(1)
    end

    it "does not let its controller cast a nonland card from the top" do
      ResolvePermanent("Courser of Kruphix", owner: p1)
      bears = Card("Grizzly Bears", owner: p1)
      p1.library.add(bears, 0)
      p1.add_mana(generic: 1, green: 1)

      expect(p1.prepare_cast(card: bears).can_perform?).to be(false)
    end

    it "reveals the top card of its controller's library to everyone" do
      ResolvePermanent("Courser of Kruphix", owner: p1)
      ability = game.battlefield.static_abilities.find { _1.respond_to?(:reveals_top_card?) }

      expect(ability.reveals_top_card?(p1)).to be(true)
      expect(ability.reveals_top_card?(p2)).to be(false)
    end
  end
end
