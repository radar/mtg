# frozen_string_literal: true

RSpec.describe Magic::Cards::ChromaticOrrery do
  include_context "two player game"

  subject(:orrery) { ResolvePermanent("Chromatic Orrery", owner: p1) }

  context "tap ability — add {C}{C}{C}{C}{C}" do
    let(:mana_ability) { orrery.activated_abilities.first }

    it "adds 5 colorless mana" do
      p1.activate_ability(ability: mana_ability)
      expect(p1.mana_pool[:colorless]).to eq(5)
    end
  end

  context "{5}, {T} ability — draw a card for each color among permanents you control" do
    let(:draw_ability) { orrery.activated_abilities.last }

    context "when you control permanents of two colors" do
      before do
        ResolvePermanent("Grizzly Bears", owner: p1)   # green
        ResolvePermanent("Selfless Savior", owner: p1) # white
      end

      it "draws two cards (one per color)" do
        p1.add_mana(colorless: 5)
        expect do
          p1.activate_ability(ability: draw_ability) do
            _1.pay_mana(generic: { colorless: 5 })
          end
          game.stack.resolve!
        end.to change { p1.hand.count }.by(2)
      end
    end

    context "when you control no colored permanents (only the artifact itself)" do
      it "draws zero cards" do
        p1.add_mana(colorless: 5)
        expect do
          p1.activate_ability(ability: draw_ability) do
            _1.pay_mana(generic: { colorless: 5 })
          end
          game.stack.resolve!
        end.not_to change { p1.hand.count }
      end
    end
  end

  context "static ability — you may spend mana as though it were mana of any color" do
    before { orrery } # ensure Chromatic Orrery is on the battlefield

    it "allows spending off-color mana to cast a colored spell" do
      blue_card = Card("Grizzly Bears", owner: p1) # green {1}{G}
      p1.add_mana(blue: 2) # no green at all

      expect do
        action = p1.prepare_cast(card: blue_card)
        action.pay_mana(generic: { blue: 1 }, blue: 1)
        action.perform
      end.not_to raise_error
    end

    it "allows spending off-color mana to activate a non-creature ability" do
      draw_ability = orrery.activated_abilities.last
      p1.add_mana(green: 5) # no colorless, but green

      expect do
        p1.activate_ability(ability: draw_ability) do
          _1.pay_mana(generic: { green: 5 })
        end
      end.not_to raise_error
    end
  end
end
