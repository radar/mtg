module Magic
  module Cards
    BilboThiefInTheNight = Creature("Bilbo, Thief in the Night") do
      cost generic: 1, blue: 1
      legendary_creature_type "Halfling Rogue"
      power 2
      toughness 2
    end

    class BilboThiefInTheNight < Creature
      # "Spells you cast from anywhere other than your hand cost {1} less to cast."
      class CostReduction < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          super(source:, adjustment: { generic: -1 })
        end

        def applies_to?(card)
          (card.controller || card.owner) == source.controller && card.zone && !card.zone.hand?
        end
      end

      def static_abilities = [CostReduction]

      # "Whenever Bilbo attacks, you may cast an artifact, instant, or sorcery spell from your graveyard. If an instant or
      # sorcery spell cast this way would be put into your graveyard, exile it instead."
      class CastChoice < Magic::Choice::May
        def prompt = "Cast an artifact, instant, or sorcery spell from your graveyard."

        def choices
          controller.graveyard.cards.select { |card| card.artifact? || card.instant? || card.sorcery? }
        end

        def target_choices
          Magic::Targets::Choices.new(choices:, amount: 1)
        end

        def single_target?
          true
        end

        # `payment`: the mana for the spell (its cost, less {1} from Bilbo); `targets`: what the spell targets, if anything.
        def resolve!(target:, payment: {}, targets: [])
          raise ArgumentError, "#{target.name} isn't a castable card in the graveyard" unless choices.include?(target)

          target.exile_instead_of_graveyard = true if target.instant? || target.sorcery?
          controller.cast(card: target, by_effect: true) do |action|
            action.pay_mana(**payment) if payment.any?
            action.targeting(*targets) if targets.any?
          end
        end
      end

      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        def call
          choice = CastChoice.new(actor: actor)
          game.choices.add(choice) if choice.choices.any?
        end
      end

      def event_handlers = super.merge(Events::FinalAttackersDeclared => AttacksTrigger)
    end
  end
end
