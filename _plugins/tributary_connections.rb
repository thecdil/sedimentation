# frozen_string_literal: true

# Tributary Connections Generator
# Parses tributary markdown files to extract trib-button connections
# Generates /assets/data/connections.json for visualization

module TributaryConnections
  class ConnectionsGenerator < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
      connections = []

      # Process each tributary file
      site.collections['tributaries'].docs.each do |trib|
        # Read the raw markdown content
        content = File.read(trib.path)

        # Split into H2 sections
        sections = content.split(/^## /)

        sections[1..-1]&.each do |section|
          # Extract section title (first line)
          lines = section.split("\n")
          section_title = lines.first.strip
          section_id = Jekyll::Utils.slugify(section_title)

          # Find all trib-button includes in this section
          section.scan(/\{%\s*include\s+feature\/trib-button\.html\s+(.*?)\s*%\}/).each do |match|
            params = match[0]

            # Extract parameters
            trib_match = params.match(/trib="([^"]+)"/)
            text_match = params.match(/text="([^"]+)"/)

            next unless trib_match

            trib_value = trib_match[1]

            # Parse target (handle both "trib/#section" and "trib" formats)
            if trib_value.include?('/#')
              parts = trib_value.split('/#')
              target_trib = parts[0].gsub('/', '')
              target_section = parts[1]
            elsif trib_value.include?('#')
              parts = trib_value.split('#')
              target_trib = parts[0].gsub('/', '')
              target_section = parts[1]
            else
              target_trib = trib_value.gsub('/', '')
              target_section = nil
            end

            button_text = text_match ? text_match[1] : target_trib.capitalize

            connections << {
              'source_trib' => trib.data['slug'],
              'source_section' => section_id,
              'source_title' => section_title,
              'target_trib' => target_trib,
              'target_section' => target_section,
              'button_text' => button_text
            }
          end
        end
      end

      # Create a page with the connections data
      site.pages << ConnectionsPage.new(site, connections)
    end
  end

  class ConnectionsPage < Jekyll::Page
    def initialize(site, connections)
      @site = site
      @base = site.source
      @dir = 'assets/data'
      @name = 'connections.json'

      self.process(@name)
      self.data = {}
      self.data['layout'] = nil
      self.data['permalink'] = '/assets/data/connections.json'

      # Generate JSON content
      self.content = JSON.pretty_generate({ 'connections' => connections })
    end
  end
end
