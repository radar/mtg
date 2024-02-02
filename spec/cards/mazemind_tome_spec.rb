require "spec_helper"

RSpec.describe Magic::Cards::MazemindTome do
  include_context "two player game"

  subject { ResolvePermanent("Mazemind Tome") }


  context "taps, puts a page counter on mazemind tome, scries one" do
    let(:ability) { subject.activated_abilities.first }

    it "activates the ability" do
      p1.activate_ability(ability: ability)

      expect(subject.counters.of_type(Magic::Counters::Page).count).to eq(1)

      choice = game.choices.last
      expect(choice).to be_a(Magic::Choice::Scry)

      game.resolve_choice!(top: [], bottom: choice.choices)
    end
  end
  context "pay 2, taps, puts a page counter, draws a card" do
    let(:ability) { subject.activated_abilities[1] }

    it "activates the ability" do
      expect(p1).to receive(:draw!)

      p1.add_mana(blue: 2)
      p1.activate_ability(ability: ability) do
        _1.pay_mana(generic: { blue: 2 })
      end

      expect(subject.counters.of_type(Magic::Counters::Page).count).to eq(1)
    end
  end

  it "when there are four or more page counters, exile it. Gain 4 life." do
    subject.add_counter(Magic::Counters::Page, amount: 4)

    expect(subject.card.zone).to be_exile
    expect(p1.life).to eq(24)
  end
end
