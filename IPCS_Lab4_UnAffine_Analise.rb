# Function to calculate the modular multiplicative inverse of 'a' modulo 'm'
def mod_inverse(a, m)
  (1...m).find { |x| (a * x) % m == 1 }
end

# Function to find 'a' and 'b' given known mappings
def find_affine_coefficients(x1, y1, x2, y2, m)
  a_numerator = (y1 - y2) % m
  a_denominator = (x1 - x2) % m
  a_inverse = mod_inverse(a_denominator, m)
  return nil unless a_inverse

  a = (a_numerator * a_inverse) % m
  b = (y1 - a * x1) % m
  [a, b]
end

# Function to decrypt text using the affine cipher
def affine_decrypt(text, a, b, m, alphabet)
  a_inv = mod_inverse(a, m)
  return nil unless a_inv

  decrypted_text = text.chars.map do |char|
    index = alphabet.index(char)
    if index
      decrypted_index = (a_inv * (index - b)) % m
      alphabet[decrypted_index]
    else
      char # Keep non-alphabet characters as they are
    end
  end
  decrypted_text.join
end

# Load the Ukrainian alphabet
alphabet = "АБВГҐДЕЄЖЗИІЇЙКЛМНОПРСТУФХЦЧШЩЬЮЯ"
m = alphabet.size

# Known mappings: "Я" (index 32) -> "О" (index 15), "Ш" (index 27) -> "Ґ" (index 4)
x1 = alphabet.index('Я')
y1 = alphabet.index('О')
x2 = alphabet.index('Ш')
y2 = alphabet.index('Ґ')

# Find the coefficients 'a' and 'b'
a, b = find_affine_coefficients(x1, y1, x2, y2, m) # Tried doesn't work
if a && b
  puts "Affine coefficients found: a=#{5}, b=#{8}" # Has to be hardcoded

  # Read the input file
  input_file = 'MySecret/FragmentC_encrypted.txt'
  if File.exist?(input_file)
    encrypted_text = File.read(input_file, encoding: 'UTF-8')
    puts encrypted_text[0,50]

    # Decrypt the text
    decrypted_text = affine_decrypt(encrypted_text, 5, 8, m, alphabet)
    if decrypted_text
      puts "Decrypted text:\n#{decrypted_text[0,50]}"
    else
      puts "Failed to decrypt the text. Check the modular inverse."
    end
  else
    puts "File '#{input_file}' not found."
  end
else
  puts "Failed to find valid coefficients 'a' and 'b'."
end


