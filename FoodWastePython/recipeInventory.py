import sqlite3

class RecipeInventory:
     
    def __init__(self):
        self.connect = sqlite3.connect("recipeInv.db")
        self.db = self.connect.cursor()

    def createDatabase(self):
        self.db.execute("CREATE TABLE recipes(id, ingredientId, quantity)")
        self.db.execute("CREATE TABLE recipeNames(id, name)")

        self.connect.commit()

    def addRecipe(self, id: int, name: str):
        self.db.execute("INSERT INTO recipeNames VALUES(?, ?)", (id, name))

        self.connect.commit()

    def addIngredient(self, id: int, ingredientId: int, quantity: float):
        self.db.execute("INSERT INTO recipes VALUE(?, ?, ?)", (id, ingredientId, quantity))

        self.connect.commit()

    def deleteRecipe(self, id: int):
        self.db.execute("DELETE FROM recipes WHERE id=?", (id))
        self.db.execute("DELETE FROM recipeNames WHERE id=?", (id))

        self.connect.commit()

    def deleteIngredient(self, id: int, ingredientId: int):
        self.db.execute("DELETE FROM recipes WHERE id=? AND ingredientId=?", (id, ingredientId))

        self.connect.commit()


    def retrieveIngredients(self, id: int):
        ingredients = {}
        for row in self.db.execute("SELECT ingredientId, quantity FROM inventory WHERE id=? ORDER BY expiration", (id,)):
            id = int(row[0])
            quantity = float(row[1])
            
            ingredients[id] += quantity

        return (ingredients)

    def getAllIds(self):
        ids = set()
        for row in self.db.execute("SELECT id FROM recipeNames"):
            ids.add(int(row[0]))
        return ids
