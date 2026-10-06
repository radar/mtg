require "spec_helper"

RSpec.describe Magic::Cards::BeseechTheMirror do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:spell) { Card("Beseech The Mirror", owner: p1) }
  let(:target) { Card("Mind Stone", owner: p1) }

  def cast(bargain_with: nil)
    p1.hand.add(spell)
    p1.library.add(target)
    p1.add_mana(black: 4)
    p1.cast(card: spell) do |action|
      action.pay_mana(black: 3, generic: { black: 1 })
      action.pay_kicker(bargain_with) if bargain_with
    end
    game.stack.resolve!
  end

  it "searches the library for a card and puts it into your hand" do
    cast
    game.resolve_choice!(target: target)

    expect(p1.hand.by_name("Mind Stone").count).to eq(1)
  end

  context "when bargained" do
    let!(:enchantment) { ResolvePermanent("Phyrexian Arena", owner: p1) }

    it "sacrifices an enchantment as it is cast" do
      cast(bargain_with: enchantment)

      expect(game.battlefield.permanents).not_to include(enchantment)
      expect(spell).to be_bargained
    end

    it "lets you cast the exiled card for free if its mana value is 4 or less" do
      cast(bargain_with: enchantment)
      game.resolve_choice!(target: target)

      expect(target.zone).to be_exile
      choice = game.choices.last
      expect(choice).to be_a(described_class::CastExiledChoice)
      game.resolve_choice!
      game.stack.resolve!

      expect(game.battlefield.permanents.map(&:name)).to include("Mind Stone")
      expect(p1.hand.by_name("Mind Stone").count).to eq(0)
    end

    it "puts the exiled card into your hand if you decline to cast it" do
      cast(bargain_with: enchantment)
      game.resolve_choice!(target: target)
      game.skip_choice!

      expect(p1.hand.by_name("Mind Stone").count).to eq(1)
    end

    it "puts a card with mana value above 4 into your hand" do
      big = Card("Farewell", owner: p1)
      p1.library.add(big)
      p1.hand.add(spell)
      p1.add_mana(black: 4)
      p1.cast(card: spell) do |action|
        action.pay_mana(black: 3, generic: { black: 1 })
        action.pay_kicker(enchantment)
      end
      game.stack.resolve!
      game.resolve_choice!(target: big)

      expect(game.choices).to be_empty
      expect(p1.hand.by_name("Farewell").count).to eq(1)
    end
  end

  it "does not let you bargain with something that is not an artifact, enchantment or token" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(black: 4)

    expect {
      p1.cast(card: spell) do |action|
        action.pay_mana(black: 3, generic: { black: 1 })
        action.pay_kicker(bears)
      end
    }.to raise_error(ArgumentError, /Bargain/)
  end
end
