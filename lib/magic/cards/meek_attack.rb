module Magic
  module Cards
    MeekAttack = Enchantment("Meek Attack") do
      cost generic: 2, red: 1
    end

    class MeekAttack < Enchantment
      # {1}{R}: You may put a creature card with total power and toughness 5 or less from your hand
      # onto the battlefield. That creature gains haste. At the beginning of the next end step,
      # sacrifice that creature.
      class PutChoice < Magic::Choice::Targeted
        def choices
          hand.creatures.select { _1.base_power + _1.base_toughness <= 5 }
        end

        def choice_amount = 1

        def resolve!(target:)
          creature = Permanent.resolve(game: game, card: target, owner: controller, from_zone: target.zone, cast: false)
          creature.grant_haste!
          creature.register_turn_trigger(Events::BeginningOfEndStep, Blitz::EndStepSacrificeTrigger)
        end
      end

      class MayChoice < Magic::Choice::May
        def resolve!
          choice = PutChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      class PutAbility < Magic::ActivatedAbility
        costs "{1}{R}"

        def resolve!
          game.choices.add(MayChoice.new(actor: source))
        end
      end

      def activated_abilities = [PutAbility]
    end
  end
end
