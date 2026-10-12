module Magic
  # Shortcuts for the `trigger_effect`s cards use most, for anything that has a `trigger_effect` (cards, abilities,
  # triggered abilities, choices, permanents):
  #
  #   create_token token: Tokens::Treasure   # trigger_effect(:create_token, token_class: Tokens::Treasure)
  #   deal_damage 3, to: target              # trigger_effect(:deal_damage, target: target, damage: 3)
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

    def draw_card
      draw_cards(1)
    end

    def draw_cards(number)
      trigger_effect(:draw_cards, number_to_draw: number)
    end

    def gain_life(life, **args)
      trigger_effect(:gain_life, life:, **args)
    end
  end
end
