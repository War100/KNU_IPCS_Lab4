# Define the Ukrainian alphabet
UKRAINIAN_ALPHABET = "АБВГҐДЕЄЖЗИІЇЙКЛМНОПРСТУФХЦЧШЩЬЮЯ".chars

# Generate a random monoalphabetic substitution key
def generate_substitution_key
  shuffled_alphabet = UKRAINIAN_ALPHABET.shuffle
  substitution_key = {}
  UKRAINIAN_ALPHABET.each_with_index do |char, index|
    substitution_key[char] = shuffled_alphabet[index]
  end
  substitution_key
end

# Encrypt the text using the substitution key
def encrypt_text(text, substitution_key)
  encrypted_text = text.chars.map do |char|
    # Encrypt only if the character is in the Ukrainian alphabet
    substitution_key[char] || char
  end
  encrypted_text.join
end

# Example usage
substitution_key = generate_substitution_key
puts "Generated substitution key:"
substitution_key.each { |k, v| puts "#{k} -> #{v}" }

# Load or input a sufficiently long piece of Ukrainian text
text = "Текст на українській мові для шифрування." # Replace with the actual text you want to encrypt

# Encrypt the text
encrypted_text = encrypt_text(text.upcase.gsub(/[A-z,[:cntrl:][:punct:]]/,''), substitution_key)
puts "\nEncrypted text:"
puts encrypted_text


