module Magic
  module Cards
    TheLonelyMountain = Card("The Lonely Mountain") do
      type T::Land, T::Lands::Mountain
    end

    class TheLonelyMountain < Card
      DwarfToken = Token.create "Dwarf" do
        creature_type "Dwarf"
        power 2
        toughness 2
        colors :red
      end

      # "This land enters tapped unless you control an Equipment."
      def enters_tapped? = !controller.permanents.by_any_type("Equipment").any?

      # "{4}{R}, {T}: Create a 2/2 red Dwarf creature token. This ability costs {1} less to activate for each Equipment
      # you control. Activate only as a sorcery."
      class DwarfAbility < Magic::ActivatedAbility
        def costs
          [
            Costs::Mana.new(generic: 4, red: 1).adjusted_by(generic: -> { -source.controller.permanents.by_any_type("Equipment").count }),
            *Costs::Parser.parse(source: source, costs: "{T}"),
          ]
        end

        activate_only_as_sorcery

        def resolve!
          trigger_effect(:create_token, token_class: DwarfToken, controller: controller)
        end
      end

      # The Mountain land type gives it "{T}: Add {R}" on its own.
      def activated_abilities = [DwarfAbility]
    end
  end
end
