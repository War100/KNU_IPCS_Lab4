require 'csv'

# Load frequency data from CSV
def load_frequencies(file_path)
  frequencies = {}
  CSV.foreach(file_path, headers: true) do |row|
    letter = row['Символ']
    frequency = row['Імовірність'].to_f
    frequencies[letter] = frequency
  end
  frequencies
end

# Analyze single-letter frequencies in the text
def analyze_single_letter_frequency(text)
  frequencies = Hash.new(0)
  text.each_char { |char| frequencies[char] += 1 }
  total_chars = frequencies.values.sum.to_f
  frequencies.transform_values { |count| count / total_chars }
end

# Analyze bigram frequencies in the text
def analyze_bigram_frequency(text)
  frequencies = Hash.new(0)
  (0...text.length - 1).each do |i|
    bigram = text[i, 2]
    frequencies[bigram] += 1
  end
  total_bigrams = frequencies.values.sum.to_f
  frequencies.transform_values { |count| count / total_bigrams }
end

# Analyze trigram frequencies in the text
def analyze_trigram_frequency(text)
  frequencies = Hash.new(0)
  (0...text.length - 2).each do |i|
    trigram = text[i, 3]
    frequencies[trigram] += 1
  end
  total_trigrams = frequencies.values.sum.to_f
  frequencies.transform_values { |count| count / total_trigrams }
end

# Initial decryption based on single-letter frequency matching
def attempt_initial_decryption(text, single_letter_freq)
  text_single_freq = analyze_single_letter_frequency(text)

  sorted_text_single = text_single_freq.sort_by { |_k, v| -v }.map(&:first)
  sorted_single_freq = single_letter_freq.sort_by { |_k, v| -v }.map(&:first)

  key = {}
  sorted_text_single.each_with_index do |enc_letter, index|
    key[enc_letter] = sorted_single_freq[index] if sorted_single_freq[index]
  end

  text.chars.map { |char| key[char] || char }.join
end

# Refine the decryption key by matching bigrams and trigrams
def refine_decryption(text, decrypted_text, bigram_freq, trigram_freq, key)
  5.times do  # Limit refinement iterations to avoid excessive swaps
    # Analyze bigrams and trigrams in the decrypted text
    text_bigram_freq = analyze_bigram_frequency(decrypted_text)
    text_trigram_freq = analyze_trigram_frequency(decrypted_text)

    # Identify the most frequent bigram/trigram mismatches
    bigram_mismatches = find_mismatches(text_bigram_freq, bigram_freq)
    trigram_mismatches = find_mismatches(text_trigram_freq, trigram_freq)

    # Attempt swaps to improve bigram and trigram matching
    (bigram_mismatches + trigram_mismatches).each do |(cipher_pair, target_pair)|
      swap_in_key(key, cipher_pair, target_pair)
      decrypted_text = text.chars.map { |char| key[char] || char }.join
    end
  end
  decrypted_text
end

# Identify mismatched bigrams or trigrams
def find_mismatches(text_freq, ref_freq)
  mismatches = []
  text_freq.each do |seq, freq|
    ref_freq_val = ref_freq[seq] || 0
    if (freq - ref_freq_val).abs > 0.01  # Arbitrary threshold for mismatch
      mismatches << [seq, find_closest_match(seq, ref_freq)]
    end
  end
  mismatches
end

# Find closest match in reference data for a given sequence
def find_closest_match(seq, ref_freq)
  ref_freq.min_by { |ref_seq, ref_freq_val| (ref_freq_val - ref_freq[seq].to_f).abs }[0]
end

# Swap characters in the key to improve match
def swap_in_key(key, from, to)
  # Swap characters in the key by adjusting the mappings
  from_chars = from.chars
  to_chars = to.chars
  from_chars.each_with_index do |fc, i|
    key[fc], key[to_chars[i]] = key[to_chars[i]], key[fc]
  end
end


# Main function
def main
  csv_path = "CSV/"
  example_text = "rfc88"
  # Load frequency data from CSV files
  single_letter_freq = load_frequencies(csv_path + example_text + ".csv")
  bigram_freq = load_frequencies(csv_path + example_text + "_bigram.csv")
  trigram_freq = load_frequencies(csv_path + example_text + "_trigram.csv")

  # Load the encrypted text from a file
  encrypted_text = File.read("MonoAlph_Enc/OK.txt").upcase.gsub(/[A-z,[:punct:]]/,'')

  # Attempt initial decryption using single-letter frequencies
  decrypted_text = attempt_initial_decryption(encrypted_text, single_letter_freq)

  # Refine decryption using bigram and trigram frequency analysis
  key = analyze_single_letter_frequency(encrypted_text).keys.zip(single_letter_freq.keys).to_h
  decrypted_text = refine_decryption(encrypted_text, decrypted_text, bigram_freq, trigram_freq, key)

  puts "Decrypted text:\n#{decrypted_text[0,50]}"
end

main


