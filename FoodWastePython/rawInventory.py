import sqlite3
import datetime

class RawInventory:
    def __init__(self):
        self.connect = sqlite3.connect("rawInv.db", check_same_thread=False)
        self.db = self.connect.cursor()

    def createDatabase(self):
        # Modified to include a 'type' column and make 'id' an autoincrement primary key
        self.db.execute("""
            CREATE TABLE IF NOT EXISTS inventory (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                quantity INTEGER,
                name TEXT,
                purchase TEXT,
                expiration TEXT  
            )""")

        self.connect.commit()

    def resetDatabase(self):
        self.db.execute("DROP TABLE IF EXISTS inventory")
        self.createDatabase()
        self.connect.commit()

    # Modified to include 'type' parameter and no longer requires 'id' for adding an item
    def addItem(self, quantity: int, name: str, purchase: datetime.datetime,expiration: datetime.datetime):
        expiration_str = expiration.strftime("%Y-%m-%d %H:%M:%S")
        purchase_str = purchase.strftime("%Y-%m-%d %H:%M:%S")
        self.db.execute("INSERT INTO inventory (quantity, name, purchase, expiration) VALUES(?, ?, ?, ?)", (quantity, name, purchase_str, expiration_str))

        self.connect.commit()

    def deleteItem(self, name: str, purchase: datetime.datetime, expiration: datetime.datetime):
        # Convert datetime objects to strings in the same format as stored in the database
        purchase_str = purchase.strftime("%Y-%m-%d %H:%M:%S")
        expiration_str = expiration.strftime("%Y-%m-%d %H:%M:%S")
        
        # Execute the DELETE statement with the provided criteria
        self.db.execute("DELETE FROM inventory WHERE name = ? AND purchase = ? AND expiration = ?", (name, purchase_str, expiration_str))
        
        # Commit the changes to the database
        self.connect.commit()

    # Modification: 'id' now uniquely identifies an item, not its type
    def getName(self, id: int):
        return self.db.execute("SELECT name FROM inventory WHERE id=?", (id,)).fetchone()[0]

    # This method needs significant changes since 'id' is no longer the type
    # Consider using 'type' to retrieve items of a certain type and aggregate their expiration statuses
    def retrieveItem(self, name: str):
        highExpirationDays = 1
        midExpirationDays = 3
        items = {"count":0, "highExpire":0, "midExpire":0}
        
        for row in self.db.execute("SELECT expiration FROM inventory WHERE name=? ORDER BY expiration", (name,)):
            expiration_str = row[0]
            expiration_datetime = datetime.datetime.strptime(expiration_str, "%Y-%m-%d %H:%M:%S")
            days_until_expiry = (expiration_datetime - datetime.datetime.now()).days
            
            items["count"] += 1

            if days_until_expiry < highExpirationDays:
                items["highExpire"] += 1
            elif days_until_expiry < midExpirationDays:
                items["midExpire"] += 1

        return items

    # New method to get all types (distinct)
    def getAllTypes(self):
        types = set()
        for row in self.db.execute("SELECT DISTINCT type FROM inventory"):
            types.add(int(row[0]))
        return types
