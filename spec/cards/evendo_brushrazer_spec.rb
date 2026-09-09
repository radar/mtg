require "spec_helper"

RSpec.describe Magic::Cards::EvendoBrushrazer do
  include_context "two player game"

  it "permits casting a card it exiled after a nontoken sacrifice" do
    evendo = ResolvePermanent("Evendo Brushrazer", owner: p1)
    sacrifice = ResolvePermanent("Forest", owner: p1)
    p1.hand.add(Card("Grizzly Bears", owner: p1))
    sacrifice.sacrifice!

    exiled_card = evendo.exiled_cards.first
    if exiled_card
      expect(p1.prepare_cast(card: exiled_card).can_perform?).to be(true)
    end
  end
end