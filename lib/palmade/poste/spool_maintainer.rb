require 'fileutils'

module Palmade::Poste
  class SpoolMaintainer
=begin
  The var spool directory is of this format:

    spool/00
    spool/01
    spool/02
    ...
    spool/xx <-- corresponds to the number of dirs in spool path (default: 64)
=end

    def self.config
      Palmade::Poste.config
    end

    def self.initialize_spool_path
      sp = spool_path
      num_dirs = spool_dirs

      (0...num_dirs).each do |i|
        part_name = Utils.to_hex(i)
        part_path = File.join(sp, part_name)

        FileUtils.mkpath(part_path)
      end
    end

    def self.calculate_spool_path(trans_id)
      part_num = trans_id[0,2].to_i(16)
      part_name = Utils.to_hex(part_num % spool_dirs)

      File.join(spool_path, part_name, trans_id)
    end

    def self.spool_dirs
      config.spool[:dirs]
    end

    def self.spool_path
      spool_path = config.spool[:path]
      unless spool_path =~ /\A\//
        spool_path = File.join(config.working_path, spool_path)
      end
      spool_path
    end

    def self.find_spool_entries
      Dir.glob(File.join(spool_path, "**/*.meta")).collect { |e|
        if e =~ /\A(.+\/([0-9a-f]+))\.meta\Z/
          [ $~[2], e, $~[1] ]
        else
          nil
        end
      }.uniq
    end
  end
end
