require 'logger'
require './logging'
include Logging
require 'optparse'
require "erubis"

#####
#
#   Runs the statistics for a given dataset
#   IN: dataset_name source_of_tree
#   out:
#   1) Sorted and appropriate sam files
#   2) runs compare2truth
#   3) runs compare junctions
#
####

# 2015/8/10 Katharina Hayer

$logger = Logger.new(STDERR)

# Initialize logger
def setup_logger(loglevel)
  case loglevel
  when "debug"
    $logger.level = Logger::DEBUG
  when "warn"
    $logger.level = Logger::WARN
  when "info"
    $logger.level = Logger::INFO
  else
    $logger.level = Logger::ERROR
  end
end

def setup_options(args)
  options = {
    :loglevel => "error",
    :debug => false,
    :read_length => nil
  }

  opt_parser = OptionParser.new do |opts|
    opts.banner = "\nUsage: ruby compare2truth.rb [options] truth.cig sorted.sam"
    opts.separator ""
    opts.separator "truth.cig:"
    opts.separator "seq.1a  chr10 123502684 123502783 100M  123502684-123502783 - CTTAAGTATGGGGAAGGTAGAAAGTTCATTTCATTACTTATAAAATATGTCTTCTCAAGAACAAAACTGTGCTGTTACAACTCAGTGTTCAATGTGAAAT"
    opts.separator "seq.1b  chr10 123502530 123502629 100M  123502530-123502629 + AGGGAGTACTATATTCTAGGGGAAAAAACTATGCCAAGACAACAGACATGAACAGGACTGTCCTGAACAAATGGATTCCTGATGCTAACACAAGCTCCAT"
    opts.separator ""
    opts.separator "sprted.sam:"
    opts.separator "seq.1a  83  chr10 123502684 255 100M  = 123502530 -254  ATTTCACATTGAACACTGAGTTGTAACAGCACAGTTTTGTTCTTGAGAAGACATATTTTATAAGTAATGAAATGAACTTTCTACCTTCCCCATACTTAAG  * NH:i:1  HI:i:1  AS:i:192  nM:i:3"
    opts.separator "seq.1b  163 chr10 123502530 255 100M  = 123502684 254 AGGGAGTACTATATTCTAGGGGAAAAAACTATGCCAAGACAACAGACATGAACAGGACTGTCCTGAACAAATGGATTCCTGATGCTAACACAAGCTCCAT  * NH:i:1  HI:i:1  AS:i:192  nM:i:3"
    opts.separator ""
    # enumeration
    #opts.on('-a', '--algorithm ENUM', [:all, :contextmap2,
    #  :crac, :gsnap, :hisat, :mapsplice2, :olego, :rum,
    #  :star,:soap,:soapsplice, :subread, :tophat2],'Choose from below:','all: DEFAULT',
    #  'contextmap2','crac','gsnap','hisat', 'mapsplice2',
    #  'olego','rum','star','soap','soapsplice','subread','tophat2') do |v|
    #  options[:algorithm] = v
    #end

    opts.on("-d", "--debug", "Run in debug mode") do |v|
      options[:log_level] = "debug"
      options[:debug] = true
    end

    #opts.on("-o", "--out_file [OUT_FILE]",
    #  :REQUIRED,String,
    #  "File for the output, Default: overview_table.xls") do |anno_file|
    #  options[:out_file] = anno_file
    #end

    opts.on("-r", "--read_length [INT]",
      :REQUIRED,Integer,
      "read length, if not specified it will be taken from cig file") do |s|
      options[:species] = s
    end

    opts.on("-v", "--verbose", "Run verbosely") do |v|
      options[:log_level] = "info"
    end

    opts.separator ""
  end

  args = ["-h"] if args.length == 0
  opt_parser.parse!(args)
  setup_logger(options[:log_level])
  if args.length != 2
    $logger.error("You only provided #{args.length} fields, but 2 required!")
    raise "Please specify the input (truth.cig sorted.sam)"
  end
  options
end

class Stats
  def initialize()
    @total_number_of_bases_of_reads = 0
    @total_number_of_bases_aligned_correctly = 0
    @total_number_of_bases_aligned_incorrectly = 0
    @total_number_of_bases_aligned_ambiguously = 0
    @total_number_of_bases_unaligned = 0
    @total_number_of_bases_in_true_insertions = 0
    @total_number_of_bases_in_true_deletions = 0
    @total_number_of_bases_called_insertions = 0
    @total_number_of_bases_called_deletions = 0
    @insertions_called_correctly = 0
    @deletions_called_correctly = 0
  end

  attr_accessor :total_number_of_bases_of_reads,
    :total_number_of_bases_aligned_correctly,
    :total_number_of_bases_aligned_incorrectly,
    :total_number_of_bases_aligned_ambiguously,
    :total_number_of_bases_unaligned,
    :total_number_of_bases_in_true_insertions,
    :total_number_of_bases_in_true_deletions,
    :total_number_of_bases_called_insertions,
    :total_number_of_bases_called_deletions,
    :insertions_called_correctly,
    :deletions_called_correctly

  def to_s
    %{total_number_of_bases_of_reads: #{@total_number_of_bases_of_reads}
total_number_of_bases_aligned_correctly: #{@total_number_of_bases_aligned_correctly}
total_number_of_bases_aligned_incorrectly: #{@total_number_of_bases_aligned_incorrectly}
total_number_of_bases_aligned_ambiguously: #{@total_number_of_bases_aligned_ambiguously}
total_number_of_bases_unaligned: #{@total_number_of_bases_unaligned}
total_number_of_bases_in_true_insertions: #{@total_number_of_bases_in_true_insertions}
total_number_of_bases_in_true_deletions: #{@total_number_of_bases_in_true_deletions}
total_number_of_bases_called_insertions: #{@total_number_of_bases_called_insertions}
total_number_of_bases_called_deletions: #{@total_number_of_bases_called_deletions}
insertions_called_correctly: #{@insertions_called_correctly}
deletions_called_correctly: #{@deletions_called_correctly}
}
  end

  def process
    #Calc percentages TODO
  end
end

class MappingObject
  def initialize()
    # Current Pos 100
    # 95M [100,195]
    @matches = []
    # 3I [100,3]
    @insertions = []
    # 4D [100,104]
    @deletions = []
    # 123N [100,223]
    @skipped = []
    # 30S/H [100,30]
    @unaligned = []
  end

  attr_accessor :matches,
    :insertions,
    :deletions,
    :skipped,
    :unaligned

  def to_s
    %{Matches: #{matches.join(":")},
Insertions: #{insertions.join(":")},
Deletions: #{deletions.join(":")},
Skipped: #{skipped.join(":")},
Unaligned: #{unaligned.join(":")}
}
  end

end


def files_valid?(truth_cig,sam_file,options)
  l = `grep ^seq #{truth_cig} | head -1`
  l.chomp!
  l =~ /seq.(\d+)/
  first_truth = $1
  l =~ /\t([^\t]+)$/;
  options[:read_length] ||= $1.length;
  l = `tail -1 #{truth_cig}`
  l.chomp!
  l =~ /seq.(\d+)/
  last_truth = $1
  l = `grep ^seq #{sam_file} | head -1`
  l.chomp!
  l =~ /seq.(\d+)/
  first_sam = $1
  l = `tail -1 #{sam_file}`
  l.chomp!
  l =~ /seq.(\d+)/
  last_sam = $1
  unless last_sam == last_truth && first_sam == first_truth
    logger.error("Sam file and cig file don't start and end in the same sequence!")
    raise "both files must start and end with the same sequence number and must have an entry for every sequence number in between."
  end
end

def fill_mapping_object(mo, start, cigar_nums, cigar_letters)
  current_pos = start
  cigar_nums.each_with_index do |num,i|
    case cigar_letters[i]
    when "M"
      mo.matches << [current_pos, current_pos + num]
      current_pos += num
    when "I"
      mo.insertions << [current_pos, num]
    when "D"
      mo.deletions << [current_pos, current_pos + num]
      current_pos += num
    when "N"
      mo.skipped << [current_pos, current_pos + num]
      current_pos += num
    when "H","S"
      mo.unaligned << [current_pos, num]
    end
  end
end

# Returns [#matches,#misaligned]
def compare_ranges(true_ranges, inferred_ranges)
  matches = 0
  misaligned = 0
  true_ranges.each_with_index do |t1, i|
    next unless i.even?
    t2 = true_ranges[i+1]
    inferred_ranges.each_with_index do |i1, k|
      next unless k.even?
      old_matches = matches
      i2 = inferred_ranges[k+1]
      if t1 <= i1 && t2 >= i2
        matches += i2 - i1
      elsif t1 <= i1 && t2 <= i2
        matches += t2 - i1
        misaligned += i2 - t2
      elsif t1 >= i1  && t2 <= i2
        matches += t2 - t1
        misaligned += (i2 - t2) + (t1 - i1)
      elsif t1 >= i1  && t2 >= i2
        matches += i2 - t1
        misaligned += (t1 - i1)
      end
      if matches != old_matches
        inferred_ranges.delete_at(k)
        inferred_ranges.delete_at(k)
      end
      #puts misaligned
    end
  end
  inferred_ranges.each_with_index do |i1, k|
    next unless k.even?
    i2 = inferred_ranges[k+1]
    misaligned += i2-i1
  end

  [matches, misaligned]
end

def comp_base_by_base(s_sam,c_cig,stats)
  $logger.debug(s_sam.join("::"))
  $logger.debug(c_cig.join("::"))
  cig_cigar_nums = c_cig[4].split(/\D/).map { |e|  e.to_i }
  cig_cigar_letters = c_cig[4].split(/\d+/).reject { |c| c.empty? }
  sam_cigar_nums = s_sam[5].split(/\D/).map { |e|  e.to_i }
  sam_cigar_letters = s_sam[5].split(/\d+/).reject { |c| c.empty? }

  c_cig_mo = MappingObject.new()
  fill_mapping_object(c_cig_mo, c_cig[2].to_i, cig_cigar_nums, cig_cigar_letters)
  $logger.debug(c_cig_mo)

  s_sam_mo = MappingObject.new()
  fill_mapping_object(s_sam_mo, s_sam[3].to_i, sam_cigar_nums, sam_cigar_letters)
  $logger.debug(s_sam_mo)

  # How many matches?
  k = compare_ranges(c_cig_mo.matches.flatten, s_sam_mo.matches.flatten)
  puts k.join(":")
  exit
end

def process(current_group, cig_group, stats,options)
  cig_group.each do |l|
    l = l.split("\t")
    k = l[4].dup
    inserts = 0
    while k =~ /(\d+)I/
      inserts = inserts+$1.to_i
      k.sub!(/(\d+)I/,"")
    end
    stats.total_number_of_bases_in_true_insertions += inserts
    k = l[4].dup
    deletions = 0
    while k =~ /(\d+)D/
      deletions = deletions+$1.to_i
      k.sub!(/(\d+)D/,"")
    end
    stats.total_number_of_bases_in_true_deletions += deletions
    stats.total_number_of_bases_of_reads += options[:read_length]
    if current_group.length > 2
      stats.total_number_of_bases_aligned_ambiguously += options[:read_length]
    else
      current_group.each do |s|
        s = s.split("\t")
        next unless l[0] == s[0]
        if s[2] == "*"
          stats.total_number_of_bases_unaligned += options[:read_length]
        else
          if s[2] != l[1]
            stats.total_number_of_bases_aligned_incorrectly += options[:read_length]
          else
            if s[3] == l[2] && s[5] == l[4]
              stats.total_number_of_bases_aligned_correctly += options[:read_length]
              stats.insertions_called_correctly += inserts
              stats.total_number_of_bases_called_insertions += inserts
              stats.deletions_called_correctly += deletions
              stats.total_number_of_bases_called_deletions += deletions
            else
              comp_base_by_base(s,l,stats)
            end
          end
        end
      end
    end
  end
  $logger.debug(current_group.length)
  $logger.debug(cig_group[0])
end

def compare(truth_cig, sam_file, options)
  stats = Stats.new()
  $logger.debug(stats)
  truth_cig_handler = File.open(truth_cig)
  sam_file_handler = File.open(sam_file)
  current_group = []
  cig_group = []
  current_num = nil
  while !sam_file_handler.eof?
    # process one sequence name at a time
    line = sam_file_handler.readline.chomp
    next unless line =~ /^seq/
    line =~ /seq.(\d+)/
    current_num ||= $1
    if current_num == $1
      current_group << line
    else
      cig_group << truth_cig_handler.readline.chomp
      cig_group << truth_cig_handler.readline.chomp
      process(current_group, cig_group,stats,options)
      current_num = $1
      current_group = []
      cig_group = []
      current_group << line
    end
  end
  cig_group << truth_cig_handler.readline.chomp
  cig_group << truth_cig_handler.readline.chomp
  process(current_group, cig_group,stats,options)
  stats
end

def run(argv)
  options = setup_options(argv)
  truth_cig = argv[0]
  sam_file = argv[1]
  $logger.info("Options are #{options}")

  files_valid?(truth_cig,sam_file,options)
  stats = compare(truth_cig, sam_file, options)
  stats.process()
  puts stats
  $logger.info("All done!")
end

if __FILE__ == $0
  run(ARGV)
end