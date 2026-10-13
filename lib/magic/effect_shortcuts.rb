module Magic
  # Shortcuts for the `trigger_effect`s cards use most, for anything that has a `trigger_effect` (cards, abilities,
  # triggered abilities, choices, permanents):
  #
  #   create_token token: Tokens::Treasure   # trigger_effect(:create_token, token_class: Tokens::Treasure)
  #   deal_damage 3, to: target              # trigger_effect(:deal_damage, target: target, damage: 3)
  #   add_counter "+1/+1", to: target        # trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 1)
  #   destroy target                         # trigger_effect(:destroy_target, target: target)
  #   reveal_cards [top]                     # trigger_effect(:reveal_cards, target: [top])
  #   counter_spell target                  # trigger_effect(:counter_spell, target: target)
  #   bounce target                         # trigger_effect(:return_to_owners_hand, target: target)
  #   tap_permanent target                  # trigger_effect(:tap, target: target)
  #   lose_life opponent, 2                 # trigger_effect(:lose_life, target: opponent, life: 2)
  #   exile_target target                   # trigger_effect(:exile, target: target)
  #   give_keyword target, :haste          # trigger_effect(:grant_keyword, target: target, keyword: :haste)
  #   pump target, 2, 2                     # trigger_effect(:modify_power_toughness, target: target, power: 2, toughness: 2)
  #   draw_card                              # trigger_effect(:draw_cards, number_to_draw: 1)
  #   draw_cards 2
  #   gain_life 3                            # trigger_effect(:gain_life, life: 3): the controller gains it
  module EffectShortcuts
    def create_token(token:, **args)
      trigger_effect(:create_token, token_class: token, **args)
    end

    # "Deal 3 damage to target creature": `deal_damage 3, to: target`; the source is the card or ability.
    def deal_damage(damage, to:, **args)
      trigger_effect(:deal_damage, target: to, damage:, **args)
    end

    # "Put a +1/+1 counter on target creature": `add_counter "+1/+1", to: target`; `amount:` defaults to 1.
    def add_counter(counter_type, to:, amount: 1, **args)
      trigger_effect(:add_counter, counter_type:, target: to, amount:, **args)
    end

    # "Target creature gets +2/+2 until end of turn": `pump target, 2, 2` (`until_eot: false` for a lasting change).
    def pump(target, power, toughness, **args)
      trigger_effect(:modify_power_toughness, target:, power:, toughness:, **args)
    end

    # "Target creature gains haste until end of turn": `give_keyword target, :haste`. Not `grant_keyword`: a
    # permanent already has one (Permanents::Modifications) that takes only the keyword.
    def give_keyword(target, keyword, **args)
      trigger_effect(:grant_keyword, target:, keyword:, **args)
    end

    def destroy(target, **args)
      trigger_effect(:destroy_target, target:, **args)
    end

    # Not `exile`: a card already has `exile`, the zone.
    def exile_target(target, **args)
      trigger_effect(:exile, target:, **args)
    end

    # "Each opponent loses 2 life": `lose_life opponent, 2`.
    def lose_life(player, life, **args)
      trigger_effect(:lose_life, target: player, life:, **args)
    end

    # Not `tap`: every object already has Kernel#tap.
    def tap_permanent(target, **args)
      trigger_effect(:tap, target:, **args)
    end

    # "Return target creature card from your graveyard to the battlefield": `reanimate target, controller: controller`.
    # `controller:` defaults to the card's owner; `counters:` are what it enters with, as { "finality" => 1 }.
    def reanimate(target, **args)
      trigger_effect(:return_target_from_graveyard_to_battlefield, target:, **args)
    end

    # "Return target creature to its owner's hand."
    def bounce(target, **args)
      trigger_effect(:return_to_owners_hand, target:, **args)
    end

    # "Counter target spell."
    def counter_spell(target, **args)
      trigger_effect(:counter_spell, target:, **args)
    end

    # "Reveal the top card of your library": `reveal_cards [top]`; takes a list of cards.
    def reveal_cards(cards, **args)
      trigger_effect(:reveal_cards, target: cards, **args)
    end

    # `player:` defaults to the source's controller.
    def draw_card(**args)
      draw_cards(1, **args)
    end

    def draw_cards(number, player: nil, **args)
      trigger_effect(:draw_cards, number_to_draw: number, player:, **args)
    end

    def gain_life(life, **args)
      trigger_effect(:gain_life, life:, **args)
    end
  end
end
