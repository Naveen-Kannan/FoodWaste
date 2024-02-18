import cv2
import pytesseract
import easyocr
import matplotlib.pyplot as plt
import re
# Load the image

def getText(imPath):
    image = cv2.imread(imPath)

    image = image[:image.shape[1],:]
    plt.imsave("oihaeuf.jpg", image)

    # Convert the image to grayscale
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    factor = 4
    gray = cv2.resize(gray, (int(gray.shape[1]/factor),int(gray.shape[0]/factor)))

    # Increase contrast using histogram equalization
    gray = cv2.equalizeHist(gray)

    alpha = 10 # Brightness factor (adjust as needed)
    gray = cv2.convertScaleAbs(gray, alpha=alpha, beta=0)

    # Apply thresholding to binarize the image
    max_output_value = 255  # The value to assign to the pixels for which the condition is satisfied
    neighborhood_size = 11  # Block size, which decides the size of the neighborhood area
    subtract_from_mean = 2  # Constant subtracted from the mean or weighted mean
    gray = cv2.adaptiveThreshold(gray, max_output_value, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, neighborhood_size, subtract_from_mean)


    # Apply Gaussian blur to reduce noise
    gray = cv2.GaussianBlur(gray, (5, 5), 0)
    #plt.imshow(gray)
    #plt.show()

     # Initialize EasyOCR reader 
    reader = easyocr.Reader(['en'])

    # Read text from image
    result = reader.readtext(gray)

    # Extracting text from the result
    editedText = ' '.join([res[1] for res in result])
    
    editedText = ''.join(ch for ch in editedText if ch.isalnum() or ch.isspace())

    return editedText


