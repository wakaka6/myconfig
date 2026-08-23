#!/usr/bin/env ruby
# frozen_string_literal: true

require "open3"

ROOT = File.expand_path("../..", __dir__)
CONFIG = File.join(ROOT, "amethyst", "amethyst.yml")

def usage
  warn <<~USAGE
    Usage:
      amfloat list
      amfloat add <bundle-id> [--restart]
      amfloat remove <bundle-id> [--restart]
      amfloat toggle <bundle-id> [app-name] [--restart]
      amfloat frontmost
      amfloat restart
  USAGE
  exit 2
end

def shell(*argv)
  stdout, stderr, status = Open3.capture3(*argv)
  [stdout, stderr, status.success?]
end

def restart_amethyst
  shell("/usr/bin/osascript", "-e", 'tell application "Amethyst" to quit')
  sleep 0.5
  system("/usr/bin/open", "-a", "Amethyst")
end

def read_lines
  File.readlines(CONFIG, chomp: true)
end

def write_lines(lines)
  File.write(CONFIG, lines.join("\n") + "\n")
end

def floating_bounds(lines)
  start_index = lines.index { |line| line.match?(/^floating:\s*(?:\[\])?\s*$/) }
  abort "floating section not found in #{CONFIG}" unless start_index

  base_indent = lines[start_index][/^\s*/].size
  end_index = start_index + 1

  while end_index < lines.length
    line = lines[end_index]
    break if !line.strip.empty? && line[/^\s*/].size <= base_indent

    end_index += 1
  end

  [start_index, end_index]
end

def floating_entries(lines)
  start_index, end_index = floating_bounds(lines)

  lines[start_index...end_index].map do |line|
    match = line.match(/^\s*-\s+id:\s*(\S+)\s*$/)
    match && match[1]
  end.compact
end

def entry_range(lines, bundle_id)
  start_index, end_index = floating_bounds(lines)
  index = start_index + 1

  while index < end_index
    if lines[index].match?(/^\s*-\s+id:\s*#{Regexp.escape(bundle_id)}\s*$/)
      stop = index + 1
      stop += 1 while stop < end_index && !lines[stop].match?(/^\s*-\s+id:\s*\S+\s*$/)
      return index...stop
    end

    index += 1
  end

  nil
end

def normalize_floating_header(lines, start_index)
  lines[start_index] = "floating:" if lines[start_index].match?(/^floating:\s*\[\]\s*$/)
end

def add_bundle(bundle_id)
  lines = read_lines
  start_index, end_index = floating_bounds(lines)
  normalize_floating_header(lines, start_index)

  if floating_entries(lines).include?(bundle_id)
    puts "#{bundle_id} already floating"
    return false
  end

  lines.insert(end_index, "  - id: #{bundle_id}", "    window-titles: []")
  write_lines(lines)
  puts "Added #{bundle_id}"
  true
end

def remove_bundle(bundle_id)
  lines = read_lines
  range = entry_range(lines, bundle_id)

  unless range
    puts "#{bundle_id} is not floating"
    return false
  end

  lines.slice!(range)
  write_lines(lines)
  puts "Removed #{bundle_id}"
  true
end

def frontmost_bundle
  script = <<~APPLESCRIPT
    tell application "System Events"
      set appProcess to first application process whose frontmost is true
      return bundle identifier of appProcess
    end tell
  APPLESCRIPT

  stdout, stderr, ok = shell("/usr/bin/osascript", "-e", script)
  abort stderr.strip unless ok

  stdout.strip
end

args = ARGV.dup
restart = args.delete("--restart")
command = args.shift || usage

changed = false

case command
when "list"
  puts floating_entries(read_lines)
when "add"
  bundle_id = args.shift || usage
  changed = add_bundle(bundle_id)
when "remove"
  bundle_id = args.shift || usage
  changed = remove_bundle(bundle_id)
when "toggle"
  bundle_id = args.shift || usage
  app_name = args.shift || bundle_id
  if floating_entries(read_lines).include?(bundle_id)
    changed = remove_bundle(bundle_id)
    puts "#{app_name} will tile normally"
  else
    changed = add_bundle(bundle_id)
    puts "#{app_name} will float"
  end
when "frontmost"
  puts frontmost_bundle
when "restart"
  restart_amethyst
else
  usage
end

restart_amethyst if restart && changed
