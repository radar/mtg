module Magic
  module Cards
    TheJollyBalloonMan = Creature("The Jolly Balloon Man") do
      cost generic: 1, red: 1, white: 1
      legendary_creature_type "Human Clown"
      keywords :haste
      power 1
      toughness 4
    end

    class TheJollyBalloonMan < Creature
      # "{1}, {T}: Create a token that's a copy of another target creature you control, except it's a 1/1 red Balloon creature
      # in addition to its other colors and types and it has flying and haste. Sacrifice it at the beginning of the next end
      # step. Activate only as a sorcery."
      class CopyAbility < Magic::ActivatedAbility
        costs "{1}, {T}"

        def target_choices
          creatures_you_control.reject { _1 == source }
        end

        def requirements_met?
          game.can_cast_sorcery?(controller)
        end

        def resolve!(target:)
          [*trigger_effect(:create_token_copy, card: target.copiable_card)].each do |token|
            token.modify_base_power(1, until_eot: false)
            token.modify_base_toughness(1, until_eot: false)
            token.change_colors!((token.colors + [:red]).uniq, until_eot: false)
            token.add_types(T::Creatures["Balloon"], until_eot: false)
            token.grant_keyword(Cards::Keywords::FLYING, until_eot: false)
            token.grant_keyword(Cards::Keywords::HASTE, until_eot: false)
            token.register_turn_trigger(Events::BeginningOfEndStep, Blitz::EndStepSacrificeTrigger)
          end
        end
      end

      def activated_abilities = [CopyAbility]
    end
  end
end
