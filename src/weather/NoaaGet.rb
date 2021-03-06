require 'net/ftp'
require 'zlib'
require 'fileutils'
require 'tempfile'

// ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-lite/2018
usaf = [
 '726390',
'725070',
'724460',
'725155',
'723307',
'723080',
'727347',
'724070',
'724050',
'723260',
'725080',
'722115',
'722977',
'723510',
'725440',
'722900',
'722180',
'726580',
'726430',
'722230',
'724397',
'785510',
'723095',
'722050',
'722280',
'911820',
'724839',
'726400',
'703810',
'726770',
'724660',
'725128',
'726457',
'722190',
'998425',
'722486',
'722448',
'723418',
'723436',
'723630',
'722868',
'722660',
'726387',
'727470',
'726350',
'724625',
'722166',
'723750',
'722630',
'726225',
'726357',
'723495',
'722506',
'725170',
'723060',
'724515',
'727415',
'702610',
'726797',
'722340',
'726465',
'726360',
'722160',
'726379',
'723860',
'726410',
'997380',
'727550',
'997171',
'722560',
'725280',
'725260',
'727570',
'722220',
'727845',
'722950',
'722400',
'726440',
'725650',
'723560',
'722590',
'744860',
'722680',
'722255',
'723575',
'722880',
'724957',
'725945',
'722430',
'725066',
'726555',
'723240',
'725785',
'727440',
'724010',
'726650',
'725330',
'725825',
'725038',
'725645',
'724675',
'724060',
'727670',
'725360',
'726700',
'743945',
'724676',
'725020',
'723440',
'725390',
'725370',
'722700',
'722405',
'723840',
'722140',
'703950',
'725060',
'727720',
'726930',
'726060',
'724518',
'722210',
'722410',
'722447',
'917650',
'726450',
'724340',
'724320',
'702190',
'723940',
'725500',
'727450',
'726480',
'700260',
'723894',
'727730',
'724755',
'725460',
'727455',
'701330',
'911650',
'722010',
'724016',
'723150',
'725190',
'726917',
'725200',
'724940',
'727640',
'722348',
'724230',
'724760',
'785203',
'722576',
'724080',
'785430',
'723100',
'722530',
'722510',
'723650',
'726370',
'725287',
'724945',
'725300',
'724350',
'722040',
'724880',
'727344',
'725776',
'911900',
'725510',
'725350',
'724030',
'725150',
'722108',
'724930',
'722110',
'727830',
'722897',
'725720',
'724400',
'724220',
'722688',
'785260',
'747040',
'725240',
'724765',
'725450',
'723340',
'724110',
'726590',
'724500',
'725130',
'727750',
'726980',
'725480',
'702730',
'727573',
'725207',
'702000',
'722080',
'724915',
'725156',
'726070',
'722540',
'727437',
'723530',
'722740',
'724555',
'722030',
'725970',
'724290',
'723170',
'727976',
'725866',
'725865',
'725780',
'722350',
'723120',
'725210',
'724677',
'724280',
'747910',
'724210',
'722650',
'725710',
'747570',
'723990',
'722670',
'723400',
'703860',
'725037',
'724380',
'727790',
'727676',
'722505',
'725290',
'912850',
'722268',
'726620',
'785140',
'700637',
'722136',
'998427',
'722060',
'725180',
'747540',
'726510',
'722310',
'726435',
'727850',
'726170',
'723270',
'722480',
'725030',
'723925',
'722500',
'722520',
'724450',
'723035',
'727530',
'725090',
'724754',
'722039',
'703610',
'723140',
'723890',
'722020',
'726810',
'727930',
'911975',
'723086',
'722580',
'724140',
'722780',
'722070',
'722970',
'727535',
'703870',
'722260',
'725340',
'723230',
'727430',
'725320',
'724390',
'725690',
'723069']


ftp = Net::FTP.new
ftp.connect("ftp.ncdc.noaa.gov", 21)
ftp.login("anonymous", "zsvoboda@gmail.com")
ftp.passive = true


%w(2018).each do |year|
  ftp.chdir("/pub/data/noaa/isd-lite/#{year}")
  filenames = ftp.nlst('*')
  filenames.each do |filename|
    if usaf.include? filename[0..5] then
      puts "getting file #{filename}"
      ftp.getbinaryfile(filename, "../../data/#{filename[0..5]}-#{year}.tsv.gz")
    end
  end
end


# un-gzips the given IO, returning the
# decompressed version as a StringIO
def ungzip(filename)
  file = File.new(filename, "r")
  z = Zlib::GzipReader.new(file)
  unzipped = StringIO.new(z.read)
  z.close
  unzipped
end

out_file = "../../data/weather_data.csv"

open(out_file, 'w') do |f|
  f.puts "usaf,date,hour,air_temp,dew_point,pressure,wind_dir,wind_speed,condition,precipitation_1h,precipitation_6h"
  Dir.glob('../../data/*.tsv.gz').select {|e| File.file? e}.each do |file|
    puts "Processing #{file}"
    content = ungzip(file)
    content.each_line.map do |l|
      f.write "#{file[11..16]},#{l.sub!(/^(\d\d\d\d) (\d\d) (\d\d)/, '\1-\2-\3').gsub!(/[ ]+/, ',').gsub('-9999', '')}"
    end
  end
end



