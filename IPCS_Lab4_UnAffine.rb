require 'csv'

# Функція видобування імен файлів із заданої директорії
# Вхід - string | Вихід - array
def getTextFiles(directory_path)
  Dir.entries(directory_path).select { |entry| File.file?(File.join(directory_path, entry)) }
end

def rotate_char_map_once(char_map)
  # Get the keys in their original order
  keys = char_map.keys
  # Get the values in their original order
  values = char_map.values

  # Create a new hash with each value assigned to the next key
  rotated_map = {}
  keys.each_with_index do |key, index|
    rotated_key = keys[(index + 1) % keys.size]
    rotated_map[rotated_key] = values[index]
  end

  rotated_map
end


# Load letter frequencies from a CSV file
def load_frequencies_from_csv(file_path)
  frequencies = {}
  CSV.foreach(file_path, headers: true) do |row|
    letter = row['Символ']
    frequency = row['Імовірність'].to_f
    frequencies[letter] = frequency
  end
  frequencies
end

# Read and analyze the ciphered text file
def read_cipher_text(file_path)
  #File.read(file_path).upcase.gsub(/[[:space:]]/,'') #.gsub(/[^A-Z]/, '')  # Remove non-letter characters and convert to uppercase
  File.read(file_path).upcase #.gsub(/[^A-Z]/, '')  # Remove non-letter characters and convert to uppercase
end

# Function to calculate character frequencies in the text
def calculate_frequencies(text)
  frequencies = Hash.new(0)
  text.each_char { |char|  frequencies[char] += 1 }

  total_chars = text.size.to_f
  frequencies.transform_values { |count| (count / total_chars * 100).round(2) }  # Convert to percentage
end

# Sort characters by frequency
def sort_by_frequency(frequencies)
  frequencies.sort_by { |char, freq| -freq }.to_h
end

# Attempt to map cipher characters to likely plaintext characters based on frequency
def map_cipher_to_plaintext(cipher_freq, target_freq)
  sorted_target_chars = target_freq.keys
  cipher_to_plain = {}

  cipher_freq.keys.each_with_index do |cipher_char, index|
    cipher_to_plain[cipher_char] = sorted_target_chars[index] if sorted_target_chars[index]
  end

  cipher_to_plain
end

# Decrypt the ciphered text using the character mapping
def decrypt_text(cipher_text, char_map)
  cipher_text.chars.map { |char| char_map[char] || char }.join
end

# Main cryptanalysis function
def perform_cryptanalysis(cipher_file_path, freq_csv_path)
  # Load target letter frequencies from CSV
  target_frequencies = sort_by_frequency(load_frequencies_from_csv(freq_csv_path))

  # Step 1: Read and calculate frequency of each character in ciphered text
  cipher_text = read_cipher_text(cipher_file_path)
  cipher_freq = calculate_frequencies(cipher_text)
  sorted_cipher_freq = sort_by_frequency(cipher_freq)

  # Step 2: Map cipher characters to plaintext characters based on frequency
  char_map = map_cipher_to_plaintext(sorted_cipher_freq, target_frequencies)
  puts "\nchar_map: "
  puts char_map

  # Step 3: Decrypt text using the character mapping
  decrypted_text = decrypt_text(cipher_text, char_map)

  # Output results
  puts "Cipher Text Frequencies (Top 10): #{sorted_cipher_freq.to_a[0, 10].to_h}"
  puts "Character Mapping (Cipher => Plain): #{char_map}"
  puts "Decrypted Text Sample (First 500 Characters):\n#{decrypted_text[0, 500]}"
end

# Run the cryptanalysis on a specified cipher text file and frequency CSV file
freq_csv_path = "CSV/ukr_lang_frex.csv"
directory_path = 'Secret/'
file_names = getTextFiles(directory_path)
puts "Файли в директорії #{directory_path}:"
file_names.each do |file_name|
  print "\n"
  puts file_name
  input_file = File.join(directory_path, file_name)
  perform_cryptanalysis(input_file, freq_csv_path)
end


