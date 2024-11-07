require "spec_helper"

RSpec.describe Magic::Cards::Pridemalkin do
  include_context "two player game"

  let(:pridemalkin) { Card("Pridemalkin") }

  context "when pridemalkin is the only creature" do
    it "adds the counter to itself" do
      p1.add_mana(green: 3)
      p1.cast(card: pridemalkin) do
        _1.pay_mana(generic: { green: 2 }, green: 1)
      end

      game.tick!
      permanent = creatures.by_name("Pridemalkin").first
      game.resolve_choice!(target: permanent)

      game.tick!

      aggregate_failures do
        expect(permanent.power).to eq(3)
        expect(permanent.toughness).to eq(2)
        expect(permanent.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(1)
        expect(permanent.has_keyword?(:trample)).to eq(true)
      end
    end
  end

  context "when there is another creature" do
    let!(:wood_elves) { ResolvePermanent("Wood Elves") }

    it "adds the counter to wood elves" do
      p1.add_mana(green: 3)
      p1.cast(card: pridemalkin) do
        _1.pay_mana(generic: { green: 2 }, green: 1)
      end

      game.tick!
      game.resolve_choice!(target: wood_elves)

      game.tick!

      aggregate_failures do
        expect(wood_elves.power).to eq(2)
        expect(wood_elves.toughness).to eq(2)
        expect(wood_elves.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(1)
        expect(wood_elves.has_keyword?(:trample)).to eq(true)
      end
    end

    it "adds the counter to pridemalkin, wood elves doesn't get trample" do
      p1.add_mana(green: 3)
      p1.cast(card: pridemalkin) do
        _1.pay_mana(generic: { green: 2 }, green: 1)
      end

      game.tick!
      permanent = creatures.by_name("Pridemalkin").first
      game.resolve_choice!(target: permanent)

      game.tick!

      aggregate_failures do
        expect(wood_elves.power).to eq(1)
        expect(wood_elves.toughness).to eq(1)
        expect(wood_elves.has_keyword?(:trample)).to eq(false)
      end
    end
  end
end
