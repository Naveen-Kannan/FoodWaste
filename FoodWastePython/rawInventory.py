import sqlite3
import datetime


class RawInventory:
    def __init__(self):
        self.connect = sqlite3.connect("rawInv.db")
        self.db = self.connect.cursor()

    #Create the table
    def createDatabase(self):
        self.db.execute("CREATE TABLE inventory(id, name, expiration)")

        self.connect.commit()

    #Reset the table
    def resetDatabase(self):
        self.db.execute("DROP TABLE inventory")
        self.createDatabase()
        self.connect.commit()

    #Add item, needs raw product id, name, expiration
    def addItem(self, id: int, name: str, expiration: datetime.datetime):
        self.db.execute("INSERT INTO inventory VALUES(?, ?, ?)", (id, name, expiration))

        self.connect.commit()

    #Remove singular item, given its id and expiration
    def deleteItem(self, id: int, expiration: datetime.datetime):
        self.db.execute("DELETE FROM inventory WHERE id=? AND expiration=? AND ROWID IN (SELECT ROWID FROM inventory WHERE id=? AND expiration=? LIMIT 1)", (id, expiration, id, expiration))

        self.connect.commit()

    #Get name of product given its id
    def getName(self, id: int):
        return (self.db.execute("SELECT name FROM inventory WHERE id=?", (id,)).fetchone())[0]


    #Get count, number of mid-expiring, and high-expiring number of a product given its id
    def retrieveItem(self, id: int):
        highExpirationDays = 1
        midExpirationDays = 3
        items = {"count":0, "highExpire":0, "midExpire":0}
        for row in self.db.execute("SELECT expiration FROM inventory WHERE id=? ORDER BY expiration", (id,)):
            expiration = row[0]
            
            items["count"] += 1

            #print((datetime.datetime.strptime(expiration, "%Y-%m-%d %H:%M:%S") - datetime.datetime.now()).days)
            #print(items)

            if (datetime.datetime.strptime(expiration, "%Y-%m-%d %H:%M:%S") - datetime.datetime.now()).days < highExpirationDays:
                items["highExpire"] += 1
            elif (datetime.datetime.strptime(expiration, "%Y-%m-%d %H:%M:%S") - datetime.datetime.now()).days < midExpirationDays:
                items["midExpire"] += 1
            
            #print(row)

        return (items)

    #Get all ids in the table
    def getAllIds(self):
        ids = set()
        for row in self.db.execute("SELECT id FROM inventory"):
            ids.add(int(row[0]))
        return ids

