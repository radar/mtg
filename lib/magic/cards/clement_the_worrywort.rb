module Magic
  module Cards
    ClementTheWorrywort = Creature("Clement, the Worrywort") do
      legendary_creature_type "Frog Druid"
      cost generic: 1, green: 1, blue: 1
      keywords :vigilance
      power 3
      toughness 3
    end

    class ClementTheWorrywort < Creature
      # Whenever Clement or another creature you control enters, return up to one target creature you control
      # with lesser mana value to its owner's hand.
      class CreatureEnters < TriggeredAbility::EnterTheBattlefield
        class BounceChoice < Magic::Choice::Targeted
          def initialize(actor:, entered:)
            @entered = entered
            super(actor: actor)
          end

          def choices
            battlefield.controlled_by(controller).creatures.select { _1.mana_value < @entered.mana_value }
          end

          def choice_amount = 0..1

          def resolve!(target:)
            trigger_effect(:return_to_owners_hand, target: target)
          end
        end

        def should_perform? = creature? && under_your_control?

        def call
          choice = BounceChoice.new(actor: actor, entered: event.permanent)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = super.merge(Events::EnteredTheBattlefield => CreatureEnters)

      # Frogs you control have "{T}: Add {G} or {U}. Spend this mana only to cast a creature spell."
      class FrogMana < Abilities::Static::GrantActivatedAbilities
        attr_reader :source

        class ManaAbility < Magic::TapManaAbility
          choices :green, :blue

          def mana_restriction = ManaRestriction::CreatureSpells.new
        end

        def applies_to?(permanent) = permanent.controller == source.controller && permanent.type?("Frog")

        def granted_abilities = [ManaAbility]
      end

      def static_abilities = [FrogMana]
    end
  end
end
