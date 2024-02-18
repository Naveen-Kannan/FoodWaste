from flask import Flask, request, jsonify
import base64
from io import BytesIO
import barcode
import rawInventory
import datetime
import getText

app = Flask(__name__)

global rawInv
rawInv = rawInventory.RawInventory()
rawInv.createDatabase()
rawInv.resetDatabase()

global msg
msg = ""


@app.route('/sendBarcode', methods=['POST'])
def receive_barcode():
    global msg
    data = request.json
    if 'image' in data:
        image_data = data['image']
        image_bytes = base64.b64decode(image_data)
        image = BytesIO(image_bytes)

        # Process the image here (e.g., save to file)
        with open("barcode.jpeg", "wb") as f:
            f.write(image_bytes)

            product_name = barcode.get_product_name(barcode.scan_barcode())
            print(product_name)
            msg = product_name
            send_message()

        return jsonify({"status": "success", "message": "Image received and saved"}), 200
    else:
        return jsonify({"status": "error", "message": "No image data found"}), 400

@app.route('/sendExpiry', methods=['POST'])
def receive_expiry():
    global msg
    data = request.json
    if 'image' in data:
        image_data = data['image']
        image_bytes = base64.b64decode(image_data)
        image = BytesIO(image_bytes)

        # Process the image here (e.g., save to file)
        with open("expiry.jpeg", "wb") as f:
            f.write(image_bytes)

            expirationdate = getText.getText('expiry.jpeg')
            print(expirationdate)
            msg = expirationdate
            send_message()

        return jsonify({"status": "success", "message": "Image received and saved"}), 200
    else:
        return jsonify({"status": "error", "message": "No image data found"}), 400


@app.route('/sendData', methods=['POST'])
def receive_data():
    data = request.json
    print("Data received:", data)
    # Process the data here
    return jsonify({"status": "success", "message": "Data received"}), 200

@app.route('/getData', methods=['GET'])
def send_data():
    # Prepare some data to send
    print("a")
    data = {"message": "Hello from Python!"}
    return jsonify(data), 200

@app.route('/sendInventoryCommand', methods=['POST'])
def receive_inventory_command():
    global rawInv
    data = request.json
    print("Inv command received")
    print("Data received:", data)
    
    message = data['message'].split("`")
    command = message[0]
    itemName = message[1]
    quantity = int(message[2])
    purchaseDate = datetime.datetime.strptime(message[3], "%m/%d/%Y")
    expirationDate = datetime.datetime.strptime(message[4], "%m/%d/%Y")

    #print(command, itemName, quantity, purchaseDate, expirationDate)
    if (command == 'add'):
        rawInv.addItem(quantity=quantity, name=itemName, purchase=purchaseDate, expiration=expirationDate)
    if (command == 'delete'):
        rawInv.deleteItem(quantity=quantity, name=itemName, purchase=purchaseDate, expiration=expirationDate)

    # Process the data here
    return jsonify({"status": "success", "message": "Data received"}), 200

@app.route('/sendChat', methods=['POST'])
def receive_chat():
    data = request.json
    print("Data received:", data)
    # Process the data here
    return jsonify({"status": "success", "message": "Data received"}), 200

@app.route('/getChat', methods=['GET'])
def send_chat():
    # Prepare some data to send
    print("a")
    data = {"message": "Hello from Python!"}
    return jsonify(data), 200

@app.route('/getMessage', methods=['GET'])
def send_message():
    global msg

    # Prepare some data to send
    print(msg)
    data = {"message": msg}
    print("go")
    return jsonify(data), 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
