require "spec_helper"

RSpec.describe Magic::Cards::Ahriman do
  include_context "two player game"

  subject! { ResolvePermanent("Ahriman") }
  let(:wood_elves) { ResolvePermanent("Wood Elves") }

  before do
    p1.library.add(Card("Forest"))
  end

  describe "activated ability" do
    it "allows controller to draw a card by sacrificing another creature or artifact" do
      hand_size = p1.hand.cards.count
      p1.add_mana(green: 3)
      ability = subject.activated_abilities.first
      p1.activate_ability(ability: ability) do
        _1.pay_mana(generic: { green: 3 })
        _1.pay_sacrifice(wood_elves)
      end
      game.stack.resolve!
      game.tick!

      expect(p1.hand.cards.count).to eq(hand_size + 1)
    end
  end
end
