#!/usr/bin/env ruby

# import ffck members from a CSV file (full export, with all licences)

def import_ffck_from_csv(csv_file, separator = ";")
    users = {}

    header = nil
    File.open(csv_file).each_line do |line|
      if header

        # extract data from csv
        data = line.strip.split(separator)
        d = {}
        header.size.times do |i|
          k = header[i]
          v = data[i]
          if v
            d[k] = "" unless d[k]
            d[k] += v
          end
        end

        # prepare new data
        m = {}
        m["uid"] = d["PRENOM"].downcase + "." + d["NOM"].downcase.gsub(" ","-")
        m["gn"] = d["PRENOM"].capitalize
        m["sn"] = d["NOM"].capitalize
        m["cn"] = m["gn"] + " " + m["sn"]
        m["displayName"] = m["cn"]
        m["ffckNumber"] = d["CODE ADHERENT"]
        m["birthDate"] = d["NE LE"].split("/").reverse.join("-")
        m["gender"] = d["SEXE"] == "H" ? "M" : "F"
        m["street"] = d["ADRESSE"].capitalize
        m["postalCode"] = d["CODE POSTAL"]
        m["l"] = d["VILLE"].capitalize
        m["homePhone"] = d["TEL"].gsub(".","") unless d["TEL"].blank?
        m["telephoneNumber"] = d["AUTRE TEL"].gsub(".","") unless d["AUTRE TEL"].blank?
        m["mobile"] = []
        m["mobile"] << d["MOBILE"].gsub(".","") unless d["MOBILE"].blank?
        m["mobile"] << d["AUTRE MOBILE"].gsub(".","") unless d["AUTRE MOBILE"].blank?
        m["fax"] = []
        m["fax"] << d["FAX"].gsub(".","") unless d["FAX"].blank?
        m["fax"] << d["AUTRE FAX"].gsub(".","") unless d["AUTRE FAX"].blank?
        m["mail"] = []
        m["mail"] << d["EMAIL"] unless d["EMAIL"].blank?
        m["mail"] << d["AUTRE EMAIL"] unless d["AUTRE EMAIL"].blank?
        m["ffckNumberYear"] = d["DERNIERE LICENCE"]
        m["ffckNumberDate"] = "20" + d["PRISE LE"].split("/").reverse.join("-")
        infos = Hash[ d["INFORMATION"].split("&").map{|s| s.split("=", 2)} ] rescue {}
        m["medicalCertificateDate"] = infos["DATECERTIFCK"].split("/").reverse.join("-") unless infos["DATECERTIFCK"].blank?
        m["medicalCertificateDate"] = infos["DATECERTIFAPS"].split("/").reverse.join("-") unless infos["DATECERTIFAPS"].blank?
        m["medicalCertificateType"] = "Loisirs" if infos["CERTIFAPS"] == "O"
        m["medicalCertificateType"] = "Compétition" if infos["CERTIFCK"] == "O"
        m["status"] = "active"
        m["ffckClubNumber"] = "9404"
        m["ffckClubName"] = "Joinville Eau Vive"

        # prepare user
        if users[ m["uid"] ].nil?
          u = User.find( m["uid"] ) rescue User.new
          %w(uid gn sn cn displayName ffckNumber birthDate gender street postalCode l \
             homePhone telephoneNumber mobile fax mail ffckNumberYear ffckNumberDate \
             medicalCertificateDate medicalCertificateType status \
             ffckClubNumber ffckClubName).each do |k|
            unless u[k]
              u[k] = m[k] unless m[k].blank?
            end
          end
          u["ffckCategory"] = u.calculate_ffck_category unless u["ffckCategory"]
          u.save!
          users[ u["uid"] ] = u
        end

      else
        header = line.strip.split(separator)
      end
    end
    users
end

import_ffck_from_csv "adherents_full.csv", ";"

