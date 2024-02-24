require "spec_helper"

RSpec.describe Magic::Cards::SublimeEpiphany do
  include_context "two player game"

  let(:sublime_epiphany) { Card("Sublime Epiphany") }

  it "counters target spell" do
    shock = Card("Shock")
    p2.add_mana(red: 1)
    p2.cast(card: shock) do
      _1.pay_mana(red: 1)
      _1.targeting(p1)
    end

    mode_class = sublime_epiphany.modes.first

    shock_cast = game.stack.first

    p1.add_mana(blue: 6)
    p1.cast(card: sublime_epiphany) do
      _1.choose_mode(mode_class) do |mode|
        mode.targeting(shock_cast)
      end
      _1.auto_pay_mana
    end

    game.tick!

    counter_event = game.current_turn.events.select { |e| e.is_a?(Magic::Events::SpellCountered) }.first
    expect(counter_event.spell).to eq(shock)

    expect(shock.zone).to be_graveyard
    expect(p1.life).to eq(20)
  end

  it "counters target activated ability" do
    igneous_cur = ResolvePermanent("Igneous Cur", owner: p2)

    p2.add_mana(red: 2)
    p2.activate_ability(ability: igneous_cur.activated_abilities.first) do
      _1.pay_mana(generic: { red: 1 }, red: 1)
    end

    ability_activation = game.stack.first

    # Counter target activated or triggered ability
    mode_class = sublime_epiphany.modes[1]

    p1.add_mana(blue: 6)
    p1.cast(card: sublime_epiphany) do
      _1.choose_mode(mode_class) do |mode|
        mode.targeting(ability_activation)
      end
      _1.auto_pay_mana
    end

    game.tick!

    counter_event = game.current_turn.events.select { |e| e.is_a?(Magic::Events::AbilityCountered) }.first
    expect(counter_event.ability).to eq(igneous_cur.activated_abilities.first)

    expect(igneous_cur.power).to eq(1)
  end
end
