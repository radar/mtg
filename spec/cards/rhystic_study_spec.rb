require "spec_helper"

RSpec.describe Magic::Cards::RhysticStudy do
  include_context "two player game"

  let!(:rhystic_study) { ResolvePermanent("Rhystic Study", owner: p1) }

  context "when opponent casts spell" do
    let!(:wood_elves_1) { Card("Wood Elves") }

    it "p2 casts 1 wood elf, p2 doesn't pay the 1, p1 draws" do
      expect(p1).to receive(:draw!)
      p2.add_mana({green: 4})
      p2.cast(card: wood_elves_1) do
        _1.pay_mana(generic: {green: 2}, green: 1)
      end

      choice = game.choices.first
      expect(choice).to be_a(Magic::Cards::RhysticStudy::Choice)
      choice.choose(mana: nil)

      game.tick!
    end

    it "p1 casts 1 wood elf, Rhystic Study doesn't trigger" do
      expect(p1).to_not receive(:draw!)
      p1.add_mana({green: 4})
      p1.cast(card: wood_elves_1) do
        _1.pay_mana(generic: {green: 2}, green: 1)
      end

      choice = game.choices.first
      expect(choice).to be_nil

      game.tick!
    end

    it "p2 casts 1 wood elf, p2 pays the 1, p1 doesn't draws" do
      expect(p1).to_not receive(:draw!)
      p2.add_mana({green: 4})
      p2.cast(card: wood_elves_1) do
        _1.pay_mana(generic: {green: 2}, green: 1)
      end

      choice = game.choices.first
      expect(choice).to be_a(Magic::Cards::RhysticStudy::Choice)
      choice.choose(mana: {green: 1})

      game.tick!
    end

    it "p2 casts 1 wood elf, p2 tries to pay 3, which is not allowed" do
      expect {
        expect(p1).to_not receive(:draw!)
        p2.add_mana({green: 7})
        p2.cast(card: wood_elves_1) do
          _1.pay_mana(generic: {green: 2}, green: 1)
        end

        choice = game.choices.first
        expect(choice).to be_a(Magic::Cards::RhysticStudy::Choice)
        choice.choose(mana: {green: 3})

        game.tick!
      }.to raise_error(/Must only pay 1 mana if paying/)
    end
  end
end
