
# HACK : localize the Time.strftime method
class Time
  alias :strftime_nolocale :strftime

  ABBR_DAYNAMES_FR = %w( Dim Lun Mar Mer Jeu Ven Sam )
  DAYNAMES_FR = %w( Dimanche Lundi Mardi Mercredi Jeudi Vendredi Samedi )
  ABBR_MONTHNAMES_FR = [nil] + %w( Jan Fév Mars Avr Mai Juin Juil Août Sept Oct Nov Déc )
  MONTHNAMES_FR = [nil] + %w( Janvier Février Mars Avril Mai Juin Juillet Août Septembre Octobre Novembre Décembre )

  def strftime(format, locale = 'en')
    if locale == 'fr'
      format = format.dup
      format.gsub!(/%a/, ABBR_DAYNAMES_FR[self.wday])
      format.gsub!(/%A/, DAYNAMES_FR[self.wday])
      format.gsub!(/%b/, ABBR_MONTHNAMES_FR[self.mon])
      format.gsub!(/%B/, MONTHNAMES_FR[self.mon])
    end
    self.strftime_nolocale(format)
  end
end

