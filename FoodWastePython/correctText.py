from datetime import datetime
from rapidfuzz import process
from liveFeed import liveFeed
from getText import getText
from fuzzywuzzy import process
from dateutil.parser import parse, ParserError
from collections import Counter



# Define possible month abbreviations
months = ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"]
def filterTextList(textList):
    filteredTextList = []
    for text in textList:
        corrected_word, score = process.extractOne(text.lower(), months) #return a closeness score
        if text.isalnum() and len(text) <= 4:
            if text.isalpha() and score > 30:
                filteredTextList.append(text)
            elif text.isnumeric() and int(text) > 0 and int(text) < datetime.now().year + 10: #eliminate any numbers that are less than 0, and greater than 10 plus current year
                filteredTextList.append(text)
    return filteredTextList

def correctMonthAbbreviation(text):
    # Split the text into words and process each word
    corrected_text = []
    for word in text.split():
        # Find the closest month abbreviation 
        corrected_word, score = process.extractOne(word.lower(), months) #return a closeness score
        if score > 30:  # You might need to adjust this threshold
            corrected_text.append(corrected_word)
    return " ".join(corrected_text)

def getDate(imPath):
    textList = getText(imPath).split()
    textList = filterTextList(textList)
    # Correct the month abbreviations
    for i in range(len(textList)):
        if textList[i].isalpha():
            textList[i] = correctMonthAbbreviation(textList[i].replace("\n", ""))
            
    def isValidDate(string):
        try:
        # Attempt to parse the string into a date
            parsed_date = parse(string)
            # Optional: Additional validation checks here
            return True
        except ParserError:
            # Parsing failed, the string is not a valid date
            return False
    newDate = ""
    for i in range(len(textList)):
        if textList[i] != "":
            date = textList[i].lower().replace(".", "-").replace("/", "-").replace(",","-")
            print(date)
            if (i == 0):
                newDate += date
            else:
                newDate = newDate + "-" + date 
    if isValidDate(newDate):
        return "Expiration date: " + newDate
    else:
        return "No date found/invalid date"

# Example usage
def main():
    val = getDate('pocky.jpg')
    print(val)

if __name__ == "__main__":
    main()