# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BardsCompany do
  include_context "two player game"

  def recruit_with(discard)
    game.settle!
    game.resolve_choice!(card: discard)
    game.settle!
  end

  def soldiers = p1.creatures.select { _1.token? && _1.type?("Human") && _1.type?("Soldier") }

  it "is a 2/3 Human Citizen" do
    company = ResolvePermanent("Bard's Company", owner: p1)

    expect([company.power, company.toughness]).to eq([2, 3])
    expect(company.card.types).to include("Human", "Citizen")
  end

  it "gives other creatures you control +1/+1, not itself or an opponent's" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    company = ResolvePermanent("Bard's Company", owner: p1, settle: false)
    game.tick!

    expect(bears.power).to eq(3)
    expect(theirs.power).to eq(2)
    expect(company.power).to eq(2)
  end

  describe "flash" do
    def cast_company
      p1.add_mana(white: 2, blue: 2)
      p1.cast(card: Card("Bard's Company", owner: p1)) { |a| a.pay_mana(generic: { white: 1, blue: 1 }, white: 1, blue: 1) }
    end

    it "can be cast at instant speed if you control a Human" do
      ResolvePermanent("Bard's Company", owner: p1, settle: false)
      game.choices.clear
      expect { cast_company }.not_to raise_error
    end

    it "can't be cast outside your main phase without a Human" do
      ResolvePermanent("Grizzly Bears", owner: p1)
      expect { cast_company }.to raise_error(Magic::IllegalAction)
    end
  end

  it "recruits when it enters, creating a Human Soldier if a nonland card is discarded" do
    nonland = Card("Shock", owner: p1)
    p1.hand.add(nonland)
    ResolvePermanent("Bard's Company", owner: p1)
    recruit_with(nonland)

    expect(soldiers.size).to eq(1)
    expect(nonland.zone).to be_graveyard
  end

  it "recruits when it attacks" do
    company = ResolvePermanent("Bard's Company", owner: p1)
    game.settle!
    game.choices.clear
    nonland = Card("Shock", owner: p1)
    p1.hand.add(nonland)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: company, target: p2)
    current_turn.attackers_declared!
    recruit_with(nonland)

    expect(soldiers.size).to eq(1)
  end
end
