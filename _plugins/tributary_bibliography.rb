module TributaryBibliography
  class Generator < Jekyll::Generator
    priority :low

    def generate(site)
      tributaries = site.collections["tributaries"]&.docs || []
      entries = []
      seen = {}

      tributaries.each do |doc|
        doc.content.to_s.each_line do |line|
          match = line.match(/^\[\^[^\]]+\]:\s*(.+)\s*$/)
          next unless match

          entry = normalize_entry(match[1])
          next if entry.empty?
          next if shortened_entry?(entry)

          key = dedupe_key(entry)
          next if seen[key]

          seen[key] = true
          entries << entry
        end
      end

      site.data["complete_bibliography"] = entries
    end

    private

    def normalize_entry(entry)
      entry.to_s.gsub(/\s+/, " ").strip
    end

    def dedupe_key(entry)
      entry.downcase.gsub(/[[:space:]]+/, " ").strip
    end

    def shortened_entry?(entry)
      short_author_page = /^\(?\s*(qtd\.\s+in\s+)?[a-z][^\.]{0,80},\s*(pp?\.?\s*\d+[\d\-\s,]*)\s*\)?\.?$/i
      bare_author_or_fragment = /^\(?\s*[a-z][a-z'\-\s]{1,40}(\s+\d+)?\s*\)?\.?$/i
      parenthetical_short = /^\([^)]+\d+[^)]*\)$/

      return true if entry.length < 20
      return true if entry.match?(short_author_page)
      return true if entry.match?(parenthetical_short)

      # Catch terse one-token/fragment citations like "Tape" or "Farmer".
      entry.match?(bare_author_or_fragment)
    end
  end
end
