#!/usr/bin/env ruby
# scripts/convert_obsidian_images.rb
# ruby >= 2.4

require 'cgi'
require 'find'

# Ищем ![[assets/...]] с опциональным |alt и опциональным #anchor (anchor игнорируется)
PATTERN = /!\[\[assets\/([^\]\|#]+)(?:\|([^\]]+))?(?:#[^\]]+)?\]\]/i


def process_file(path)
  text = File.read(path, encoding: 'utf-8')
  new_text = text.gsub(PATTERN) do
    rel = $1.strip                     # путь относительно assets/, без "assets/"
    raw_path = "assets/#{rel}"         # полный путь внутри сайта
    alt_text = ($2 ? $2.strip : File.basename(rel)).strip
    alt_text = CGI.escapeHTML(alt_text)

    src = raw_path.start_with?('/') ? "{{ site.baseurl }}#{raw_path}" : "{{ site.baseurl }}/#{raw_path}"
    %Q{<img src="#{src}" alt="#{alt_text}" />}
  end

  if new_text != text
    File.write(path, new_text, encoding: 'utf-8')
    puts "Updated: #{path}"
  end
end

# По умолчанию только ./_notes (можно указать другой путь в аргументе)
root = ARGV[0] || './_notes'

unless Dir.exist?(root)
  warn "Directory not found: #{root}. Nothing to do."
  exit 0
end

Find.find(root) do |p|
  if File.directory?(p)
    dir = File.basename(p)
  else
    if p =~ /\.(md|markdown)$/i
      process_file(p)
    end
  end
end
