#!/usr/bin/env ruby

require 'fileutils'
require 'yaml'
require 'erb'

APP_NAME = 'Asteroids'
BUILD_DIR = "build/#{APP_NAME}.app/Contents"
BINARY = 'asteroids'
BREW_LIBS = ["sdl2"]
MACOS_MIN_VER = "10.14"

def gather_libs(file)
  libs = `otool -L #{file}`.lines
    .map { |l| l[/^.+\.dylib/i]&.strip }
    .reject do |l|
      l.nil? ||
      l.empty? ||
      l.start_with?("/System/Library") ||
      l.start_with?("/usr/lib") ||
      l.start_with?("@rpath")
    end

  libs.each do |l_path|
    lib_name = File.basename(l_path)
    dest_dir = "#{BUILD_DIR}/Frameworks"
    dest_path = "#{dest_dir}/#{lib_name}"

    puts "#{lib_name}"

    if File.exist?("#{BUILD_DIR}/Frameworks/#{lib_name}")
      puts " - Skipping #{lib_name}: Already present"
      next
    end

    unless File.exist? dest_path
      begin
        puts " - Copy #{l_path} to #{dest_path}"
        FileUtils.cp l_path, dest_path
      rescue Errno::EACCES => e
        puts " - ERROR: #{l_path} cannot be copied: #{e}"
        exit 1
      end
    end

    `chown $(id -u):$(id -g) #{dest_path} && chmod +w #{dest_path}`

    unless $?.success?
      puts "Could not change ownership and add write permissions to #{dest_path}"
      exit 1
    end

    patch_cmd = "install_name_tool -change #{l_path} @executable_path/../Frameworks/#{lib_name} #{file}"
    puts " - Patching executable link: \n   - #{patch_cmd}"
    `#{patch_cmd}`
    unless $?.success?
      exit 1
    end

    # Recursive copy
    gather_libs dest_path
  end
end

puts "Creating structure for #{APP_NAME}:"
[
  BUILD_DIR,
  "#{BUILD_DIR}/MacOS",
  "#{BUILD_DIR}/Resources",
  "#{BUILD_DIR}/Frameworks",
].each do |folder|
  puts "  Create: #{folder}"
  FileUtils.mkdir_p folder
end

puts "Copying files"
{
  "Info.plist" => "#{BUILD_DIR}/"
}.each do |source, dest|
  puts "  Copy: #{source} => #{dest}"
  FileUtils.cp source, dest
end

link_flags = [
  "-rpath @executable_path/../Frameworks",
  "-mmacosx-version-min=#{MACOS_MIN_VER}",
  "-headerpad_max_install_names",
]

BREW_LIBS.each do |lib|
  link_flags << "-L #{`brew --prefix #{lib}`.chomp}/lib/"
end

if File.exist?("bin/#{BINARY}")
  FileUtils.rm "bin/#{BINARY}"
end

puts "Building: \n  #{link_flags.join("\n  ")}"
cmd = %{shards build #{BINARY} --release --link-flags="#{link_flags.join(" ")}"}
puts cmd
puts `#{cmd}`

FileUtils.cp "bin/#{BINARY}", "#{BUILD_DIR}/MacOS/#{BINARY}"

puts "Gathering libs..."
gather_libs "#{BUILD_DIR}/MacOS/#{BINARY}"

puts "Done!"
