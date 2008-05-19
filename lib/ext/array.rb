class Array #:nodoc:
  
  # Extraceted from Ruby Facets:
  # Converts a two-element associative array into a hash.
  def to_h(arrayed=nil)
    h = {}
    if arrayed
      each{ |k,*v| h[k] = v }
    else
      ary = []
      each do |a|
        Array===a ? ary.concat(a) : ary << a
      end
      h = Hash[*ary]
    end
    h
  end
end