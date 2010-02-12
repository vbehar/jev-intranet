
# HACK : localize the Date.strftime method
class Date
  alias :strftime_nolocale :strftime

  ABBR_DAYNAMES = %w( Dim Lun Mar Mer Jeu Ven Sam )
  DAYNAMES = %w( Dimanche Lundi Mardi Mercredi Jeudi Vendredi Samedi )
  ABBR_MONTHNAMES = [nil] + %w( Jan Fév Mars Avr Mai Juin Juil Août Sept Oct Nov Déc )
  MONTHNAMES = [nil] + %w( Janvier Février Mars Avril Mai Juin Juillet Août Septembre Octobre Novembre Décembre )

  def strftime(format)
    format = format.dup
    format.gsub!(/%a/, ABBR_DAYNAMES[self.wday])
    format.gsub!(/%A/, DAYNAMES[self.wday])
    format.gsub!(/%b/, ABBR_MONTHNAMES[self.mon])
    format.gsub!(/%B/, MONTHNAMES[self.mon])
    self.strftime_nolocale(format)
  end
end

