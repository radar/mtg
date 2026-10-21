module Magic
  module Cards
    HopeEnderCoatl = Creature("Hope-Ender Coatl") do
      cost generic: 2, blue: 1
      power 2
      toughness 2
      creature_type "Eldrazi Snake"
      keywords :devoid, :flash, :flying
    end

    class HopeEnderCoatl < Creature
      # Counter target spell an opponent controls unless they pay {1}.
      class CounterChoice < Magic::Choice::Targeted
        def choices = game.stack.spells.select { |spell| spell.player != controller }

        def choice_amount = 1

        def resolve!(target:)
          choice = Magic::Choice::CounterUnlessPay.new(actor: actor, spell: target, mana: { generic: 1 })
          if choice.can_pay?
            game.choices.add(choice)
          else
            counter_spell(target)
          end
        end
      end

      # When you cast this spell, ...
      class CastTrigger < TriggeredAbility::CastThisSpell
        def call
          choice = CounterChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def cast_triggers = [CastTrigger]
    end
  end
end
