module Magic
  module Cards
    RinAndSeriInseperable = Creature("Rin and Seri, Inseparable") do
      cost "{1}{R}{G}{W}"
      type "Legendary Creature — Dog Cat"
      power 4
      toughness 4
    end

    class RinAndSeriInseperable < Creature
      CatToken = Token.create "Cat" do
        type "Creature —- Cat"
        power 1
        toughness 1
        colors :green
      end

      DogToken = Token.create "Dog" do
        type "Creature —- Dog"
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

      def activated_abilities = [ActivatedAbility]

      def event_handlers
        {
          Events::SpellCast => -> (receiver, event) do
            return unless event.spell.controller == receiver.controller
            if event.spell.type?("Dog")
              controller.create_token(token_class: CatToken)
            end

            if event.spell.type?("Cat")
              controller.create_token(token_class: DogToken)
            end
          end
        }
      end
    end
  end
end
