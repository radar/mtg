module Magic
  # Shortcuts for the `trigger_effect`s cards use most, for anything that has a `trigger_effect` (cards, abilities,
  # triggered abilities, choices, permanents):
  #
  #   create_token token: Tokens::Treasure   # trigger_effect(:create_token, token_class: Tokens::Treasure)
  #   draw_card                              # trigger_effect(:draw_cards, number_to_draw: 1)
  #   draw_cards 2
  #   gain_life 3                            # trigger_effect(:gain_life, life: 3): the controller gains it
  module EffectShortcuts
    def create_token(token:, **args)
      trigger_effect(:create_token, token_class: token, **args)
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
