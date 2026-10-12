require "spec_helper"

RSpec.describe Magic::Cards::Farewell do
  include_context "two player game"

  it "is a six-mana sorcery" do
    expect(Card("Farewell").mana_value).to eq(6)
  end

  describe "when cast" do
    before { go_to_main_phase! }

    def cast_with(*mode_classes)
      farewell = Card("Farewell", owner: p1)
      p1.hand.add(farewell)
      p1.add_mana(white: 6)
      p1.cast(card: farewell) do |action|
        action.pay_mana(generic: { white: 4 }, white: 2)
        mode_classes.each { |mode| action.choose_mode(mode) }
      end
      game.settle!
    end

    it "exiles every creature, targeting none, when that mode is chosen" do
      mine = ResolvePermanent("Grizzly Bears", owner: p1)
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      enchantment = ResolvePermanent("Font of Fertility", owner: p1)

      cast_with(Magic::Cards::Farewell::ExileCreatures)

      expect(game.battlefield.permanents).not_to include(mine, theirs)
      expect(game.battlefield.permanents).to include(enchantment)
    end

    it "can combine modes" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      enchantment = ResolvePermanent("Font of Fertility", owner: p1)

      cast_with(Magic::Cards::Farewell::ExileCreatures, Magic::Cards::Farewell::ExileEnchantments)

      expect(game.battlefield.permanents).not_to include(bears, enchantment)
    end

    it "requires at least one mode" do
      expect { cast_with }.to raise_error(Magic::Actions::Cast::InvalidModes)
    end
  end
end
