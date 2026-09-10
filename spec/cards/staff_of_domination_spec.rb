# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StaffOfDomination do
  include_context "two player game"

  subject!(:staff) { ResolvePermanent("Staff Of Domination", owner: p1) }
  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

  it "untaps itself for {1}" do
    staff.tap!
    p1.add_mana(green: 1)
    p1.activate_ability(ability: staff.activated_abilities[0]) do
      _1.pay_mana(generic: { green: 1 })
    end
    game.stack.resolve!

    expect(staff).to be_untapped
  end

  it "gains 1 life for {2}, {T}" do
    p1.add_mana(green: 2)
    expect {
      p1.activate_ability(ability: staff.activated_abilities[1]) do
        _1.pay_mana(generic: { green: 2 })
      end
      game.stack.resolve!
    }.to change { p1.life }.by(1)
    expect(staff).to be_tapped
  end

  it "untaps target creature for {3}, {T}" do
    wood_elves.tap!
    p1.add_mana(green: 3)
    p1.activate_ability(ability: staff.activated_abilities[2]) do
      _1.pay_mana(generic: { green: 3 })
      _1.targeting(wood_elves)
    end
    game.stack.resolve!

    expect(wood_elves).to be_untapped
    expect(staff).to be_tapped
  end

  it "taps target creature for {4}, {T}" do
    p1.add_mana(green: 4)
    p1.activate_ability(ability: staff.activated_abilities[3]) do
      _1.pay_mana(generic: { green: 4 })
      _1.targeting(wood_elves)
    end
    game.stack.resolve!

    expect(wood_elves).to be_tapped
    expect(staff).to be_tapped
  end

  it "draws a card for {5}, {T}" do
    p1.add_mana(green: 5)
    expect {
      p1.activate_ability(ability: staff.activated_abilities[4]) do
        _1.pay_mana(generic: { green: 5 })
      end
      game.stack.resolve!
    }.to change { p1.hand.count }.by(1)
    expect(staff).to be_tapped
  end
end
