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

  it "returns target nonland permanent to its owner's hand" do
    igneous_cur = ResolvePermanent("Igneous Cur", owner: p2)

    # return target nonland permanent
    mode_class = sublime_epiphany.modes[2]

    p1.add_mana(blue: 6)
    p1.cast(card: sublime_epiphany) do
      _1.choose_mode(mode_class) do |mode|
        mode.targeting(igneous_cur)
      end
      _1.auto_pay_mana
    end

    game.tick!

    expect(p2.hand).to include(igneous_cur.card)
  end

  it "creates a token that's a copy of target creature you control" do
    igneous_cur = ResolvePermanent("Igneous Cur", owner: p1)

    mode_class = sublime_epiphany.modes[3]

    p1.add_mana(blue: 6)
    p1.cast(card: sublime_epiphany) do
      _1.choose_mode(mode_class) do |mode|
        mode.targeting(igneous_cur)
      end
      _1.auto_pay_mana
    end

    game.tick!

    expect(game.battlefield.creatures.by_name("Igneous Cur").count).to eq(2)
  end


  it "creates a token that's a copy of target creature you control" do
    expect(p1).to receive(:draw!)

    mode_class = sublime_epiphany.modes[4]

    p1.add_mana(blue: 6)
    p1.cast(card: sublime_epiphany) do
      _1.choose_mode(mode_class)
      _1.auto_pay_mana
    end

    game.tick!
  end

  it "chooses all the modes" do

    shock = Card("Shock")
    p2.add_mana(red: 1)
    p2.cast(card: shock) do
      _1.pay_mana(red: 1)
      _1.targeting(p1)
    end

    first_mode = sublime_epiphany.modes.first

    shock_cast = game.stack.first

    igneous_cur_p2 = ResolvePermanent("Igneous Cur", owner: p2)

    p2.add_mana(red: 2)
    p2.activate_ability(ability: igneous_cur_p2.activated_abilities.first) do
      _1.pay_mana(generic: { red: 1 }, red: 1)
    end

    second_mode = sublime_epiphany.modes[1]
    ability = game.stack.first

    third_mode = sublime_epiphany.modes[2]

    fourth_mode = sublime_epiphany.modes[3]
    fifth_mode = sublime_epiphany.modes[4]

    igneous_cur_p1 = ResolvePermanent("Igneous Cur", owner: p1)


    expect(p1).to receive(:draw!)
    p1.add_mana(blue: 6)
    p1.cast(card: sublime_epiphany) do
      _1.choose_mode(first_mode) do |mode|
        mode.targeting(shock_cast)
      end
      _1.choose_mode(second_mode) do |mode|
        mode.targeting(ability)
      end

      _1.choose_mode(third_mode) do |mode|
        mode.targeting(igneous_cur_p2)
      end

      _1.choose_mode(fourth_mode) do |mode|
        mode.targeting(igneous_cur_p1)
      end

      _1.choose_mode(fifth_mode)

      _1.auto_pay_mana
    end

    game.tick!

    expect(game.battlefield.creatures.by_name("Igneous Cur").count).to eq(2)
  end
end
