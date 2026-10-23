module Magic
  module Cards
    NyxbornUnicorn = Creature("Nyxborn Unicorn") do
      enchantment_creature_type("Unicorn")
      cost generic: 1, white: 1
      keywords :mentor
      bestow Costs::Mana.new(generic: 3, white: 1)
      power 2
      toughness 2
    end

    class NyxbornUnicorn < Creature
      # "Enchanted creature gets +2/+2 and has mentor."
      def power_modification = 2

      def toughness_modification = 2

      def keyword_grants = [Keywords::MENTOR]

      # Mentor: "Whenever this creature attacks, put a +1/+1 counter on target attacking creature with lesser power."
      # The Unicorn has it as a creature; while bestowed, the enchanted creature has it, so the Aura reads the host.
      class MentorTrigger < TriggeredAbility
        class CounterChoice < Magic::Choice::Targeted
          attr_reader :mentor

          def initialize(actor:, mentor:)
            super(actor: actor)
            @mentor = mentor
          end

          def choices = battlefield.creatures.attacking.select { _1.power < mentor.power }

          def choice_amount = 1

          def resolve!(target:)
            target.add_counter("+1/+1")
          end
        end

        def mentor = actor.bestowed_now? ? actor.attached_to : actor

        def should_perform? = event.attacker == mentor

        def call
          choice = CounterChoice.new(actor: actor, mentor: mentor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = super.merge({ Events::CreatureAttacked => MentorTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
