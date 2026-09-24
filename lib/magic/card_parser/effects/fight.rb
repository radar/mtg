# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "~ fights target creature you don't control." / "Enchanted creature fights up
      # to one target creature an opponent controls." (Permanents::Creature#fights!)
      class Fight < Data.define(:fighter, :reference)
        include Effect

        FIGHTERS = { "~" => Effect::THIS, "enchanted creature" => "#{Effect::THIS}.attached_to",
                     "equipped creature" => "#{Effect::THIS}.attached_to" }.freeze
        LINE = /\A(?<fighter>~|enchanted creature|equipped creature) fights #{PermanentTarget::PATTERN}\.?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text)) && m[:kind].downcase == "creature"

          new(fighter: FIGHTERS.fetch(m[:fighter].downcase), reference: PermanentTarget.reference(m))
        end

        def target_choices = reference.choices
        def optional_target? = reference.optional
        def resolve_call = "#{fighter}.fights!(target)"
      end
    end
  end
end
