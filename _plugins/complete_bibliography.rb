module CompleteBibliography
  class Generator < Jekyll::Generator
    priority :low

    def generate(site)
      entries = []
      seen = {}

      site.collections.fetch("tributaries", []).docs.each do |doc|
        in_works_cited = false

        doc.content.to_s.each_line do |line|
          stripped = line.strip

          if stripped.match?(/^##\s+Works Cited\s*$/i)
            in_works_cited = true
            next
          end

          if in_works_cited && stripped.match?(/^##\s+/)
            in_works_cited = false
            next
          end

          next unless in_works_cited

          match = stripped.match(/^\[\^[^\]]+\]:\s*(.+)\s*$/)
          next unless match

          entry = normalize(match[1])
          next if entry.empty?
          next if shortened_entry?(entry)
          next unless complete_entry?(entry)

          key = dedupe_key(entry)
          next if seen[key]

          seen[key] = true
          entries << entry
        end
      end

      sorted = entries.sort_by(&:downcase)
      site.data["complete_bibliography"] = sorted
      site.config["complete_bibliography"] = sorted
    end

    private

    def normalize(entry)
      entry.to_s.gsub(/\s+/, " ").strip
    end

    def dedupe_key(entry)
      entry
        .downcase
        .gsub(/\[[^\]]+\]\([^\)]+\)/, "")
        .gsub(/,\s*pp?\.?\s*\d+[\d\-\s,]*/i, "")
        .gsub(/[[:space:]]+/, " ")
        .gsub(/[[:punct:]]+/, "")
        .strip
    end

    def shortened_entry?(entry)
      return true if entry.match?(/^\([^)]+\)\.?$/)
      return true if entry.match?(/^qtd\.\s+in/i)
      return true if entry.match?(/^\(?\s*[a-z][a-z'\-\s]{1,80},\s*pp?\.?\s*\d+[\d\-\s,]*\s*\)?\.?$/i)
      return true if entry.match?(/^\(?\s*[a-z][a-z'\-\s]{1,80}\s*\)?\.?$/i)

      false
    end

    def complete_entry?(entry)
      has_person_name = entry.match?(/\A\s*[^,]{2,80},\s*[^\.\n]{2,120}/)
      has_title = entry.include?("*") || entry.match?(/["“”]/)
      has_publisher = entry.match?(/\b(press|university|books|book|journal|magazine|department|museum|publishing|publisher|house)\b/i)

      has_person_name && (has_title || has_publisher)
    end
  end
end
