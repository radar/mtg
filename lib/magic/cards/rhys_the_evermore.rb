module Magic
  module Cards
    class RhysTheEvermore < Creature
      card_name "Rhys, the Evermore"
      cost generic: 1, white: 1
      legendary_creature_type "Elf Warrior"
      power 2
      toughness 2
      keywords :flash

      class PersistChoice < Magic::Choice::Targeted
        def choices = controller.creatures.except(actor)

        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:grant_keyword, target:, keyword: :persist)
        end
      end

      # "When Rhys enters, another target creature you control gains persist until end of turn."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          choice = PersistChoice.new(actor:)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # Answer with `remove: { Magic::Counters::Minus1Minus1 => 2, ... }`.
      class RemoveCountersChoice < Magic::Choice
        attr_reader :creature

        def initialize(actor:, creature:)
          super(actor:)
          @creature = creature
        end

        def choices = creature.counters.map(&:class).uniq

        def resolve!(remove: {})
          remove.each do |type, amount|
            available = creature.counters.of_type(type).size
            raise ArgumentError, "#{creature.name} has only #{available} #{type} counters" if amount > available

            creature.remove_counter(counter_type: type, amount:) if amount.positive?
          end
        end
      end

      # "{W}, {T}: Remove any number of counters from target creature you control. Activate only as
      # a sorcery."
      class RemoveCountersAbility < Magic::ActivatedAbility
        costs "{W}, {T}"

        def requirements_met? = game.can_cast_sorcery?(controller)

        def target_choices = controller.creatures

        def resolve!(target:)
          choice = RemoveCountersChoice.new(actor: source, creature: target)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]

      def activated_abilities = [RemoveCountersAbility]
    end
  end
end
