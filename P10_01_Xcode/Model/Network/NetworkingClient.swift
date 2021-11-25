//
//  Recipe.swift
//  Reciplease
//
//  Created by Fabien Saint Germain on 02/11/2021.
//

import Foundation
import Alamofire

class NetworkingClient {
    
    static var shared = NetworkingClient()
    
    private init() {}
        
    static let parameters = [
        "app_id": ApiToken.edamamId, "app_key": ApiToken.edamamKey,
        "q": NetworkingClient.shared.makeIngredientsList(), "type": "public"
    ]
    
    private var ingredientListRequest: String {
        makeIngredientsList()
    }
    var ingredientsList: [String] = []
    
    var nextPage = ""
    var paginationFinished = true
    
    func makeIngredientsList() -> String {
        var ingredientRequest = ""
        ingredientsList.forEach { ingredient in
            ingredientRequest += ingredient + " "
        }

        return ingredientRequest
    }
    
    func clearIngredientsList() {
        ingredientsList = []
    }
    
    func deleteIngredient(at index: Int){
        ingredientsList.remove(at: index)
    }
        
    func switchRequest(_ requestStatus: RequestStatus) -> DataRequest {
        switch requestStatus {
        case .initial:
            return AF.request("https://api.edamam.com/api/recipes/v2", parameters: NetworkingClient.parameters)
        case .following:
            return AF.request(nextPage)
        }
    }
    
    func displayIngredientName(_ ingredientsList: [Ingredient]) -> String {
        var returningString = ""
        ingredientsList.forEach { ingredient in
            returningString += ingredient.food + ", "
        }
        returningString.removeLast(2)
        return returningString
    }
    
    func displayIngredientQuantity(_ ingredientsList: [Ingredient]) -> String {
        var returningString = ""
        ingredientsList.forEach { ingredient in
            returningString += "-" + ingredient.text + "\n"
        }
        returningString.removeLast(1)
        return returningString
    }
    
    func checkIngredient() -> Bool {
        if ingredientsList.isEmpty {
            return false
        } else {
            return true
        }
    }
}

extension NetworkingClient: RequestManager {

    
    func fetchData(_ requestStatus: RequestStatus, successHandler: @escaping ([Recipe]) -> Void, errorHandler: @escaping (String) -> Void) {
        paginationFinished = false
        print(8)
        print(ingredientListRequest)
        let request = switchRequest(requestStatus)
        print(9)
        request.validate().responseDecodable(of: RecipeDecoder.self) { responseJSON in
            print(10)
            switch responseJSON.result {
            case .success :
                guard let JSON = responseJSON.value?.hits,
                      let nextPageURL = responseJSON.value?._links.next.href else {
                   return errorHandler("No data")
                }
                print(11)
                let result = self.createRecipe(JSON)
                self.nextPage = nextPageURL.description
                print(15)
                successHandler(result)
            case .failure :
                return errorHandler("Ingredients not recognized")
            }
            self.paginationFinished = true
            print(17)
        }
    }
    
    func createRecipe(_ responseArray: [RecipeDecoder.Hit]) -> [Recipe] {
        print(12)
        var onlineRecipies: [Recipe] = []
         responseArray.forEach { response in
             let ingredients = response.recipe.ingredients
             let recipe = Recipe(
                 name: response.recipe.label, image: response.recipe.image, recipeURL: response.recipe.url,
                 duration: String(response.recipe.totalTime), notation: String(response.recipe.yield), ingredients: displayIngredientName(ingredients),
                 ingredientsQuantity: displayIngredientQuantity(ingredients), isFavorite: false)
             print("13bis")
             onlineRecipies.append(recipe)
         }
        print(14)
         return onlineRecipies
    }
    
    
}

