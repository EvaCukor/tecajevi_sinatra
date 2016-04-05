require 'sinatra'
require 'open-uri'
require 'json'

url = "http://www.hnb.hr/hnb-tecajna-lista-portlet/rest/tecajn/getformatedrecords.dat"

helpers do
  def load_data_into_array(source_file)
    arr = []
    open(source_file, "r") do |f|
      f.each_line do |line|
        arr << line.split
      end
    end
    
    return arr
  end

  def build_hash_with_data(arr)
    hash = {}

    hash[:broj_tecajnice] = arr[0][0][0..2].to_i
    hash[:datum_izrade] = arr[0][0][7..10].to_s + "/" + arr[0][0][5..6].to_s + "/" + arr[0][0][3..4].to_s
    hash[:datum_primjene] = arr[0][0][15..18].to_s + "/" + arr[0][0][13..14].to_s + "/" + arr[0][0][11..12].to_s

    arr.shift

    hash[:valute] = []

    arr.each do |item|
      currency_hash = {}
      currency_hash[:sifra] = item[0][0..2]
      currency_hash[:oznaka] = item[0][3..5]
      currency_hash[:jedinica] = item[0][6..8].to_i
      # vrijednosti tecaja ostavljene su kao stringovi jer se u hrvatskom zarez koristi kao decimalni separator, a točka kao separator tisućica, inače u obzir dolazi i ovo rješenje: currency_hash[:kupovni_tecaj] = item[1].gsub!(',', '.').to_f
      currency_hash[:kupovni_tecaj] = item[1]   
      currency_hash[:srednji_tecaj] = item[2]
      currency_hash[:prodajni_tecaj] = item[3]
      hash[:valute] << currency_hash
    end
    
    return hash
  end
end


get '/' do
  array = load_data_into_array(url)
  temp_hash = build_hash_with_data(array)
  
  content_type :json
  JSON.pretty_generate(temp_hash)
end