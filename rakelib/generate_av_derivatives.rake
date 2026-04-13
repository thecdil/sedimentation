###############################################################################
# TASK: generate_av_derivatives
#
# Generate small and thumb image derivatives from audio/video files using ffmpeg.
# Requires ffmpeg to be installed and on PATH.
#
# VIDEO (mp4): extracts a still frame at a given second
# AUDIO (mp3): renders a waveform or spectrogram image
#
# Usage examples:
#
# NOTE: zsh treats square brackets as glob patterns. Always quote the task name
# when passing arguments, e.g.: rake 'generate_av_derivatives[3,spectrogram]'
#
#   rake generate_av_derivatives                                           # all defaults
#   rake 'generate_av_derivatives[10]'                                     # video frame at 10s
#   rake 'generate_av_derivatives[3,waveform]'                             # audio as waveform (default)
#   rake 'generate_av_derivatives[3,spectrogram]'                          # audio as spectrogram
#   rake 'generate_av_derivatives[3,waveform,450x,800x800,true,objects]'   # all args
#
# Arguments (positional, all optional):
#   second            - video: timestamp in seconds to capture (default: 3)
#   audio_vis         - audio visualization style: 'waveform' or 'spectrogram' (default: waveform)
#   thumbs_size       - ImageMagick geometry for thumb output (default: 450x)
#   small_size        - ImageMagick geometry for small output (default: 800x800)
#   missing           - 'true' skips files whose derivatives already exist (default: true)
#   input_dir         - directory containing av files (default: objects)
###############################################################################

require 'mini_magick'

# Resize a source image to two derivative sizes (thumb and small).
# source_path  - path to an existing JPEG/PNG to resize
# base         - lowercase base filename without extension (used to build output names)
# thumb_dir, small_dir - destination directories
# thumbs_size, small_size - ImageMagick geometry strings
# missing      - if 'true', skip files that already exist
def generate_image_derivatives(source_path, base, thumb_dir, small_dir, thumbs_size, small_size, missing)
  thumb_filename = File.join(thumb_dir, "#{base}_th.jpg")
  small_filename = File.join(small_dir, "#{base}_sm.jpg")

  if missing == 'false' || !File.exist?(thumb_filename)
    puts "  Creating thumb: #{thumb_filename}"
    img = MiniMagick::Image.open(source_path)
    img.format('jpg')
    img.resize(thumbs_size)
    img.write(thumb_filename)
  else
    puts "  Skipping thumb (already exists): #{thumb_filename}"
  end

  if missing == 'false' || !File.exist?(small_filename)
    puts "  Creating small: #{small_filename}"
    img = MiniMagick::Image.open(source_path)
    img.format('jpg')
    img.resize(small_size)
    img.write(small_filename)
  else
    puts "  Skipping small (already exists): #{small_filename}"
  end

  [small_filename, thumb_filename]
end


desc 'Generate derivative images from mp4 video and mp3 audio files using ffmpeg'
task :generate_av_derivatives, [:second, :audio_vis, :thumbs_size, :small_size, :missing, :input_dir] do |_t, args|
  args.with_defaults(
    second: '3',
    audio_vis: 'waveform',
    thumbs_size: '450x',
    small_size: '800x800',
    missing: 'true',
    input_dir: 'objects'
  )

  # confirm ffmpeg is available before doing any work
  unless system('ffmpeg -version > /dev/null 2>&1')
    abort <<~MSG

      \e[31mError: ffmpeg was not found on your PATH.\e[0m

      ffmpeg is required to generate audio/video derivatives.
      Download and install it from: https://ffmpeg.org/download.html

      Quick install options:
        macOS (Homebrew):   brew install ffmpeg
        Linux (apt):        sudo apt install ffmpeg
        Linux (dnf):        sudo dnf install ffmpeg
        Windows:            download a build from https://ffmpeg.org/download.html
                            and add the bin/ folder to your system PATH

      After installing, rerun: rake generate_av_derivatives

    MSG
  end

  # validate audio_vis option
  unless %w[waveform spectrogram].include?(args.audio_vis)
    abort "\e[31mError: audio_vis must be 'waveform' or 'spectrogram', got '#{args.audio_vis}'.\e[0m"
  end

  objects_dir     = args.input_dir
  thumb_image_dir = File.join(objects_dir, 'thumbs')
  small_image_dir = File.join(objects_dir, 'small')

  [thumb_image_dir, small_image_dir].each do |dir|
    FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
  end

  mp4_files = Dir.glob(File.join(objects_dir, '*.mp4'))
  mp3_files = Dir.glob(File.join(objects_dir, '*.mp3'))

  if mp4_files.empty? && mp3_files.empty?
    puts "No mp4 or mp3 files found in '#{objects_dir}'."
    next
  end

  puts "Found #{mp4_files.length} mp4 and #{mp3_files.length} mp3 file(s)."

  list_name   = File.join(objects_dir, 'av_object_list.csv')
  field_names = %w[filename object_location image_small image_thumb]

  CSV.open(list_name, 'w') do |csv|
    csv << field_names

    # -------------------------------------------------------------------------
    # VIDEO: extract a still frame at the requested second
    # -------------------------------------------------------------------------
    unless mp4_files.empty?
      puts "\nProcessing video files (frame at #{args.second}s)..."
      mp4_files.each do |filepath|
        base      = File.basename(filepath, '.*').downcase
        tmp_frame = File.join(Dir.tmpdir, "#{base}_frame_#{args.second}s.jpg")

        begin
          # -ss before -i for fast seek; -vframes 1 grabs a single frame; -y overwrites tmp
          cmd = "ffmpeg -ss #{args.second} -i #{Shellwords.escape(filepath)} -vframes 1 -q:v 2 -y #{Shellwords.escape(tmp_frame)} 2>/dev/null"
          unless system(cmd)
            # video may be shorter than requested second — retry at 0s
            puts "  Warning: could not seek to #{args.second}s in #{filepath}, retrying at 0s"
            cmd0 = "ffmpeg -ss 0 -i #{Shellwords.escape(filepath)} -vframes 1 -q:v 2 -y #{Shellwords.escape(tmp_frame)} 2>/dev/null"
            unless system(cmd0)
              puts "  Error: ffmpeg failed for #{filepath}, skipping."
              csv << [File.basename(filepath), "/#{filepath}", nil, nil]
              next
            end
          end

          unless File.exist?(tmp_frame)
            puts "  Error: ffmpeg produced no output for #{filepath}, skipping."
            csv << [File.basename(filepath), "/#{filepath}", nil, nil]
            next
          end

          small_f, thumb_f = generate_image_derivatives(
            tmp_frame, base,
            thumb_image_dir, small_image_dir,
            args.thumbs_size, args.small_size, args.missing
          )
          csv << [File.basename(filepath), "/#{filepath}", "/#{small_f}", "/#{thumb_f}"]

        rescue StandardError => e
          puts "  Error processing #{filepath}: #{e.message}"
          csv << [File.basename(filepath), "/#{filepath}", nil, nil]
        ensure
          FileUtils.rm_f(tmp_frame)
        end
      end
    end

    # -------------------------------------------------------------------------
    # AUDIO: render a waveform or spectrogram image with ffmpeg
    # -------------------------------------------------------------------------
    unless mp3_files.empty?
      puts "\nProcessing audio files (#{args.audio_vis})..."
      mp3_files.each do |filepath|
        base      = File.basename(filepath, '.*').downcase
        tmp_image = File.join(Dir.tmpdir, "#{base}_#{args.audio_vis}.png")

        begin
          ffmpeg_filter =
            if args.audio_vis == 'spectrogram'
              # showspectrumpic renders frequency content over time as a color heatmap
              "showspectrumpic=s=800x200:color=intensity:scale=log"
            else
              # showwavespic renders amplitude over time (classic waveform)
              "showwavespic=s=800x200:colors=steelblue"
            end

          cmd = "ffmpeg -i #{Shellwords.escape(filepath)} -lavfi #{Shellwords.escape(ffmpeg_filter)} -y #{Shellwords.escape(tmp_image)} 2>/dev/null"
          unless system(cmd)
            puts "  Error: ffmpeg failed for #{filepath}, skipping."
            csv << [File.basename(filepath), "/#{filepath}", nil, nil]
            next
          end

          unless File.exist?(tmp_image)
            puts "  Error: ffmpeg produced no output for #{filepath}, skipping."
            csv << [File.basename(filepath), "/#{filepath}", nil, nil]
            next
          end

          small_f, thumb_f = generate_image_derivatives(
            tmp_image, base,
            thumb_image_dir, small_image_dir,
            args.thumbs_size, args.small_size, args.missing
          )
          csv << [File.basename(filepath), "/#{filepath}", "/#{small_f}", "/#{thumb_f}"]

        rescue StandardError => e
          puts "  Error processing #{filepath}: #{e.message}"
          csv << [File.basename(filepath), "/#{filepath}", nil, nil]
        ensure
          FileUtils.rm_f(tmp_image)
        end
      end
    end
  end

  puts "\n\e[32mDone. See '#{list_name}' for a list of files and their derivatives.\e[0m"
end
