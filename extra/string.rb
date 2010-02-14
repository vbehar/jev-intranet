require 'iconv'

class String

  # easy utf-8 to ascii conversion
  def to_ascii
    Iconv.iconv('ascii//translit', 'utf-8', self).to_s
  end

end

