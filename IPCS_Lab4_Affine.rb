# Affine cipher implementation in Ruby for Ukrainian language
UKR_ALPHABET = "АБВГҐДЕЄЖЗИІЇЙКЛМНОПРСТУФХЦЧШЩЬЮЯ"  # Ukrainian alphabet
ALPHABET_SIZE = UKR_ALPHABET.size

A = 5   # Multiplier key (must be coprime with ALPHABET_SIZE)
B = 8   # Shift key

# Функція видобування імен файлів із заданої директорії
# Вхід - string | Вихід - array
def getTextFiles(directory_path)
  Dir.entries(directory_path).select { |entry| File.file?(File.join(directory_path, entry)) }
end

# Check if A is coprime with ALPHABET_SIZE (must be for the affine cipher to work)
def coprime?(a, m)
  a.gcd(m) == 1
end

unless coprime?(A, ALPHABET_SIZE)
  raise "Key 'A' must be coprime with the size of the alphabet (#{ALPHABET_SIZE})."
end

# Function to get the index of a Ukrainian letter
def char_index(char)
  UKR_ALPHABET.index(char)
end

# Function to encrypt a single character
def affine_encrypt_char(char, a, b, m)
  x = char_index(char)
  if x.nil?
    char  # Return the character unchanged if it's not in the Ukrainian alphabet
  else
    encrypted_x = (a * x + b) % m
    UKR_ALPHABET[encrypted_x]
  end
end

# Function to encrypt text using the affine cipher
def affine_encrypt(text, a, b, m)
  text.upcase.chars.map do |char|
    affine_encrypt_char(char, a, b, m)
  end.join
end

# Read the text file
directory_path = 'Original/'
output_directory_path = 'Secret/'
file_names = getTextFiles(directory_path)
puts "Файли в директорії #{directory_path}:"
file_names.each do |file_name|
  print "\n"
  input_file = File.join(directory_path, file_name)
  output_file = File.join(output_directory_path, file_name.sub(/\.txt$/, '') + "_encrypted.txt")

  #text = File.read(input_file, encoding: "utf-8").upcase.gsub(/[A-z,∆[:digit:][:space:][:punct:]]/,'')
  text = File.read(input_file, encoding: "utf-8").upcase.gsub(/[A-z,∆[:cntrl:][:punct:]]/,'')
  puts "Original text:"
  puts text

  # Encrypt the text
  encrypted_text = affine_encrypt(text, A, B, ALPHABET_SIZE)

  # Write the encrypted text to a new file
  File.open(output_file, "w", encoding: "utf-8") { |file| file.write(encrypted_text) }
  puts "Text encrypted with affine cipher and saved to '#{output_file}'"
end


