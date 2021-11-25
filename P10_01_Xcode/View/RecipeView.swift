//
//  RecipeView.swift
//  Reciplease
//
//  Created by Fabien Saint Germain on 03/11/2021.
//

import UIKit
//
// MARK: - Recipe View
//

///Specific View for display informations from a Recipe
class RecipeView: UIView {
    //
    // MARK: - IBOutlets
    //
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var ingredientsQuantity: UITextView!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var notation: UILabel!
    @IBOutlet weak var recipeImage: UIImageView!

    //
    // MARK: - Internal Method
    //
    func setRecipeView(withRecipe: Recipe) {
        recipeName.text = withRecipe.name
        ingredientsQuantity.text = withRecipe.ingredientsQuantity
        duration.text = withRecipe.duration
        notation.text = withRecipe.notation
        recipeImage.loadFromURL(withRecipe.image)
    }
}

