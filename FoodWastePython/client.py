import requests

def send_data_to_server(data):
    url = 'http://127.0.0.1:5000/sendData'  # Make sure the URL matches your Flask server's address
    headers = {'Content-Type': 'application/json'}
    
    # Attempt to send the data to the server
    response = requests.post(url, json=data, headers=headers)
    
    # Check the server's response
    if response.ok:
        print("Successfully sent data to the server. Server response:", response.json())
    else:
        print("Failed to send data. Status code:", response.status_code)

if __name__ == '__main__':
    # Prompt the user for input
    user_input = input("Enter your message: ")
    
    # Prepare the data to send (convert the user input into a suitable data structure)
    data = {"message": user_input}
    
    # Send the data to the Flask server
    send_data_to_server(data)
