# Patching Array#sum method for older rubies, jruby and rubinbius
if !Array.instance_methods.include?(:sum)
  class Array
    def sum
      inject(0) {|sum, val| sum + val}
    end
  end
end

# Patching Regexp#match? method for older rubies, jruby and rubinbius
if !Regexp.instance_methods.include?(:match?)
  class Regexp
    def match?(a)
      !match(a).nil?
    end
  end
end
