//
//  CoreDataManager.swift
//  Reciplease
//
//  Created by Fabien Saint Germain on 18/11/2021.
//

import Foundation
import CoreData
//
// MARK: - Core Data Manager
//

/// A specific class for managing the Core Data "SavedRecipe" entity
/// Save a recipe, delete it, create SavedRecipe from Recipe and vice versa
class CoreDataManager {
    //
    // MARK: - Constant
    //
    static let shared = CoreDataManager()
    
    //
    // MARK: - Initialization
    //
    private init() {}

    //
    // MARK: - Internal Methods
    //
    func createRecipeOff(_ responseArray: [SavedRecipe]) -> [Recipe] {
        var recipies: [Recipe] = []
        responseArray.forEach { response in
            let recipe = Recipe(name: response.name!, image: response.image!, recipeURL: response.recipeURL!, duration: response.duration!,
                                notation: response.notation!, ingredients: response.ingredients!,
                                ingredientsQuantity: response.ingredientsQuantity!, isFavorite: true)
            recipies.append(recipe)
        }
        return recipies
    }
    
    func deleteRecipe(name: String){
        let request: NSFetchRequest<SavedRecipe> = SavedRecipe.fetchRequest()
        request.predicate = NSPredicate(format: "name LIKE %@", name)
        guard let results = try? AppDelegate.viewContext.fetch(request) else {
            return
        }
        results.forEach { recipe in
            AppDelegate.viewContext.delete(recipe)
        }
        try? AppDelegate.viewContext.save()
    }
    
    func saveRecipe(_ recipeToSave: Recipe) {
        let recipe = SavedRecipe(context: AppDelegate.viewContext)
        recipe.name = recipeToSave.name
        recipe.notation = recipeToSave.notation
        recipe.isFavorite = true
        recipe.duration = recipeToSave.duration
        recipe.image = recipeToSave.image
        recipe.recipeURL = recipeToSave.recipeURL
        recipe.ingredients = recipeToSave.ingredients
        recipe.ingredientsQuantity = recipeToSave.ingredientsQuantity
    try? AppDelegate.viewContext.save()
    }
}

//
// MARK: - Request Recipe Protocol
//
extension CoreDataManager: RequestRecipe {
    
    func createRecipe(_ responseArray: [RecipeDecoder.Hit]) -> [Recipe] {
        return []
    }
    
    func fetchRecipe(_ requestStatus: RequestStatus, successHandler: @escaping([Recipe]) -> Void, errorHandler: @escaping(String) -> Void) {
        let request: NSFetchRequest<SavedRecipe> = SavedRecipe.fetchRequest()
        guard let recipies = try? AppDelegate.viewContext.fetch(request) else {
          return errorHandler("Add a Recipe to your favorites first")
        }
        if recipies.isEmpty {
            return errorHandler("Add a Recipe to your favorites first")
        }
        let result = self.createRecipeOff(recipies)
        successHandler(result)
    }
}
