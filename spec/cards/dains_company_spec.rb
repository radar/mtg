# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DinsCompany do
  include_context "two player game"

  def p1_library
    [
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      # End initial card draw
      Card("Island"),
      Card("Dwarven Provisioner"),
      Card("Short Sword"),
      Card("Forest"),
      Card("Forest"),
    ]
  end

  let!(:company) { ResolvePermanent("Dáin's Company", owner: p1) }
  let(:choice) { game.choices.last }

  it "is a 2/2 Dwarf Warrior without lifelink while alone" do
    game.skip_choice!
    game.tick!
    expect(company.power).to eq(2)
    expect(company.type?("Dwarf")).to eq(true)
    expect(company.has_keyword?(Magic::Cards::Keywords::LIFELINK)).to eq(false)
  end

  it "has lifelink while you control another Dwarf" do
    game.skip_choice!
    ResolvePermanent("Dwarven Provisioner", owner: p1)
    game.tick!
    expect(company.has_keyword?(Magic::Cards::Keywords::LIFELINK)).to eq(true)
  end

  it "offers only Dwarf or Equipment cards from the top four" do
    expect(choice).to be_a(Magic::Choice::LookAtTopCards)
    expect(choice.choices.map(&:name)).to eq(["Dwarven Provisioner", "Short Sword"])
  end

  it "puts the chosen card in hand and the rest on the bottom" do
    picked = choice.choices.first
    game.resolve_choice!(target: picked)
    expect(p1.hand.cards).to include(picked)
    expect(p1.library.count).to eq(4)
  end
end
