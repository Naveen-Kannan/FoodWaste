from pyzbar.pyzbar import decode
import cv2
import requests

def scan_barcode():
    # Initialize the camera
    cap = cv2.VideoCapture(0)

    while True:
        # Read frame from the camera
        ret, frame = cap.read()

        # Decode barcodes
        barcodes = decode(frame)

        if barcodes:
            for barcode in barcodes:
                # Extract barcode data
                barcode_data = barcode.data.decode('utf-8')
                barcode_type = barcode.type

                # Print barcode data and type
                print("Barcode Data:", barcode_data)
                print("Barcode Type:", barcode_type)

                return barcode_data

                # Draw a rectangle around the barcode
                x, y, w, h = barcode.rect
                cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)

        # Display the frame
        cv2.imshow('Barcode Scanner', frame)

        # Exit the loop if 'q' is pressed
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    # Release the camera
    cap.release()
    cv2.destroyAllWindows()

def get_product_name(barcode_id):
    api_key = 'YOUR_API_KEY'
    url = f'https://api.upcitemdb.com/prod/trial/lookup?upc={barcode_id}'

    try:
        response = requests.get(url)
        data = response.json()
        if data['code'] == 'OK':
            print(len(data['items'][0]['offers']))
            product_names = [data['items'][0]['offers'][0]['title']]
            if (len(data['items'][0]['offers']) > 1):
                product_names.append(data['items'][0]['offers'][1]['title'])
            if (len(data['items'][0]['offers']) > 2):
                product_names.append(data['items'][0]['offers'][2]['title'])
            return product_names
        else:
            return "Product not found"
    except Exception as e:
        print("Error:", e)
        return "Error occurred"

if __name__ == "__main__":
    # Scan barcodes from the live camera feed
    print(get_product_name(scan_barcode()))
