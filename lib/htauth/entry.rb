module HTAuth
  # Internal: base class from which all entries are derived
  class Entry
    # Internal: return a new instance of this entry
    def dup
      self.class.from_line(self.to_s)
    end
  end
end
