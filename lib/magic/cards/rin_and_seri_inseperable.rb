module Magic
  module Cards
    RinAndSeriInseperable = Creature("Rin and Seri, Inseparable") do
      cost "{1}{R}{G}{W}"
      legendary_creature_type "Dog Cat"
      power 4
      toughness 4
    end

    class RinAndSeriInseperable < Creature
      CatToken = Token.create "Cat" do
        creature_type "Cat"
        power 1
        toughness 1
        colors :green
      end

      DogToken = Token.create "Dog" do
        creature_type "Dog"
        power 1
        toughness 1
        colors :white
      end

      class ActivatedAbility < ActivatedAbility
        costs "{R}{G}{W}, {T}"

        def target_choices
          game.any_target
        end

        def resolve!(target:)
          dogs = creatures_you_control.by_type("Dog")
          cats = creatures_you_control.by_type("Cat")

          trigger_effect(:deal_damage, damage: dogs.count, target: target)
          trigger_effect(:gain_life, life: cats.count, target: controller)
        end
      end

      class SpellCastTrigger < TriggeredAbility
        def should_perform?
          event.spell.controller == controller &&
            (event.spell.type?("Dog") || event.spell.type?("Cat"))
        end

        def call
          if event.spell.type?("Dog")
            trigger_effect(:create_token, token_class: CatToken)
          end

          if event.spell.type?("Cat")
            trigger_effect(:create_token, token_class: DogToken)
          end
        end
      end

      def activated_abilities = [ActivatedAbility]

      def event_handlers
        {
          Events::SpellCast => SpellCastTrigger
        }
      end
    end
  end
end
