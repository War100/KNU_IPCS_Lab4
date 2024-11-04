
require 'csv'


# Функція видобування імен файлів із заданої директорії
# Вхід - string | Вихід - array
def getTextFiles(directory_path)
    Dir.entries(directory_path).select { |entry| File.file?(File.join(directory_path, entry)) }
end

# Функція для підрахунку зустрічань символу в тексті
# Вхід - file_content | Вихід - hash
def countTrigramAmounts(file_contents)
    trigram_amounts = Hash.new(0)
    (0...file_contents.length - 1).each do |i|
        trigram = file_contents[i, 3]  # Get three consecutive characters
        trigram_amounts[trigram] += 1
    end
    trigram_amounts.sort.to_h
end

# Функція перетворення деяких спеціальних символів
# Вхід - char | Вихід - char
def convertSpecialCharacters(char)
    case char
    when "\n"
        "\\n"
    when "\t"
        "\\t"
    when "\r"
        "\\r"
    else
        char
    end
end

# Функція для підрахунку середньої ентропії в тексті
# Вхід - hash | Вихід - float
def entropyCount(char_amounts)
    average_entropy = 0.0
    char_amounts.each { |char, amount| average_entropy += ((amount.to_f/char_amounts.values.sum) * Math.log2(1 / (amount.to_f/char_amounts.values.sum)))}
    average_entropy
end

# Основна функція виконання
def main()
    begin
        puts("Program started...")
        if ARGV.empty?
            directory_path = 'Text_Examples/'
            file_names = getTextFiles(directory_path)
        else
            directory_path = ''
           file_names = ARGV
        end

        puts "Файли в директорії #{directory_path}:"
        file_names.each do |file_name|
            print "\n"

            file_path = File.join(directory_path, file_name)
            file_contents = File.read(file_path).upcase.gsub(/[A-z,∆[:space:][:digit:][:punct:]\n]/, '')
            trigram_amounts = countTrigramAmounts(file_contents)

            puts "Файл: #{file_name}"
            puts "№\t|Символ:\t|Кільк.:\t|Імовірність:\t|%\t|"
            puts "---------------------------------------------------------"

            # Розрахунок та виведення обрахованих даних
            # у форматі:
            # Ітератор(№) | Символ | Кількість зустрічань | Імовірність появи символу
            iterator = 0
            trigram_amounts.each {
                |char, amount|
                puts "#{iterator+=1})\t|\t#{convertSpecialCharacters(char)}\t|\t#{amount}\t|\t#{(amount.to_f/trigram_amounts.values.sum).round(5)}\t|\t#{(amount.to_f/trigram_amounts.values.sum * 100).round(5)}\t|" }

            amount_of_information = (entropyCount(trigram_amounts)*trigram_amounts.values.sum)/8
            puts "\nЗагальна кількість символів: #{trigram_amounts.values.sum}"
            #puts "Середня ентропія: #{entropyCount(char_amounts).round(3)}"
            #puts "Кількість інформації: #{amount_of_information.round(3)} байт"
            puts "Розмір файлу: #{File.size(file_path)} байт"
            puts "\n"
            #puts "Відношення кількості інформації до розміру файлу: #{(amount_of_information/File.size(file_path)).round(3)}"

            # Створення та виведення частини отриманої інформації у вигляді csv-файлу
            csv_options = {
            col_sep: ",",
            headers: true
            }

            CSV.open("CSV/" + file_name.sub(/\.txt$/, '') + "_trigram.csv",'w') do |csv|
                csv << ["№","Символ","Кільк.","Імовірність","%"]
                iterator = 0
                trigram_amounts.each do |row|
                    csv << [iterator+=1] + [convertSpecialCharacters(row[0])] + [row[1]] + [(row[1].to_f/trigram_amounts.values.sum).round(5)] + [(row[1].to_f/trigram_amounts.values.sum * 100).round(5)]
                end
            end

        end
        puts "\nExecution complete.\nReturn code 0"
        rescue StandardError => e
            puts "\nПомилка: #{e.message}"
    end
end

# Точка запуска програми
main()