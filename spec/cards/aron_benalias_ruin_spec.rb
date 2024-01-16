require "spec_helper"

RSpec.describe Magic::Cards::AronBenaliasRuin do
  include_context "two player game"

  subject! { ResolvePermanent("Aron, Benalia's Ruin", owner: p1) }
  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }
  let!(:aven_gagglemaster) { ResolvePermanent("Aven Gagglemaster", owner: p1) }

  it "has menace" do
    expect(subject).to have_keyword(Magic::Cards::Keywords::MENACE)
  end

  context "activated ability" do
    it "puts a +1/+1 counter on all creatures under p1's control" do
      expect(subject.activated_abilities.count).to eq(1)
      p1.add_mana(white: 1, black: 1)

      p1.activate_ability(ability: subject.activated_abilities.first) do
        _1.pay_mana(white: 1, black: 1)
        _1.pay_sacrifice(wood_elves)
      end
      game.stack.resolve!

      aggregate_failures do
        expect(subject.power).to eq(4)
        expect(subject.toughness).to eq(4)

        expect(aven_gagglemaster.power).to eq(5)
        expect(aven_gagglemaster.toughness).to eq(4)

        expect(wood_elves.card.zone).to be_graveyard
      end
    end
  end
end
