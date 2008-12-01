module HTAuth

  # base class from which all entries are derived
  class Entry
    def dup
      self.class.from_line(self.to_s)
    end
  end
end
