from pyzbar.pyzbar import decode
import cv2
import requests

def scan_barcode():
    img = cv2.imread('barcode.jpeg')
    img = img[:img.shape[1],:]

    barcodes = decode()

    if barcodes:
        for barcode in barcodes:
            # Extract barcode data
            barcode_data = barcode.data.decode('utf-8')
            barcode_type = barcode.type

            # Print barcode data and type
            print("Barcode Data:", barcode_data)
            print("Barcode Type:", barcode_type)

            return barcode_data


def get_product_name(barcode_id):
    api_key = 'YOUR_API_KEY'
    url = f'https://api.upcitemdb.com/prod/trial/lookup?upc={barcode_id}'

    try:
        response = requests.get(url)
        data = response.json()
        if data['code'] == 'OK':
            
            return data['items'][0]['title']
        else:
            return "Product not found"
    except Exception as e:
        print("Error:", e)
        return "Error occurred"
'''
if __name__ == "__main__":
    # Scan barcodes from the live camera feed
    print(get_product_name(scan_barcode()))
'''