module Magic
  class CreatureToken < Cards::Creature
    def skip_stack?
      true
    end

    def creature?
      true
    end
  end
end
