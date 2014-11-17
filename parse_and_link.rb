unless folder = ARGV.shift
  puts "Usage parse_and_link.rb <directory>"
  exit 1
end

unless File.directory?(folder)
  puts "#{folder} is not a folder"
  exit 1
end

$stdin.flush

puts "is this a tv show (t) or movie (m)?"

tv_show_or_movie = gets

unless ["t", "m"].include? tv_show_or_movie.downcase.strip
  puts "please enter t or m"
  exit 1
end

if tv_show_or_movie.downcase.strip == "t"
  show_name  = folder.split(/[sS]\d{2}/).first.gsub(".", " ").strip

  puts "Determined show name to be #{show_name}"

  season_number = folder.match(/[sS]\d{2}/).to_s.gsub(/[sS]/, "")

  puts "Determined season number o be #{season_number}"
  
  Dir.chdir(folder)

  file_extension = ".mkv"

  video_files = Dir.glob("*.mkv").sort
  if video_files.empty?
    video_files = Dir.glob("*.mp4").sort
    file_extension = ".mp4"
  end

  links = []

  video_files.each do |filename|
    puts "found #{filename}"
    
    episode_id = filename.match( /[sS]\d{2}[eE]\d{2}/ ).to_s
    
    links << {source_filename: filename, dest_filename: "#{show_name} #{episode_id.downcase}#{file_extension}"}
  end

  puts "going to make the following links"
  links.each do |link|
    puts "#{File.join(Dir.pwd, link[:source_filename])} -> /home/whatbox/tv-shows/#{show_name}/Season #{season_number}/#{link[:dest_filename]}"
  end

  puts "continue? (y/n)"
  continue = gets
  
  unless continue == "y\n"
    exit
  end

  system("mkdir -p '/home/whatbox/tv-shows/#{show_name}/Season #{season_number}'")

  puts "making links..."
  
  links.each do |link|
    system("ln -s '#{File.join(Dir.pwd, link[:source_filename])}' '/home/whatbox/tv-shows/#{show_name}/Season #{season_number}/#{link[:dest_filename]}'")
  end

  puts "fixing folder permissions...."
  system "chmod o+x '#{Dir.pwd}'"
  system "chmod o+r -R '#{Dir.pwd}'"

  puts "done"
  
end

# binding.pry
