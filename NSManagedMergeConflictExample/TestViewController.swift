//
//  TestViewController.swift
//  NSManagedMergeConflictExample
//
//  Created by Kevin Yu on 1/29/19.
//  Copyright © 2019 Kevin Yu. All rights reserved.
//

import UIKit

final class TestViewController: UIViewController {

    var coreData = CoreDataManager()
    
    @IBOutlet var coreDataValueLabel: UILabel!
    @IBOutlet var mergePolicyButtons: [UIButton]!
    @IBOutlet var context1TextField: UITextField!
    @IBOutlet var context2TextField: UITextField!
    
    /// currently-selected Merge policy
    var currMergePolicy: MergePolicyAdapter = MergePolicyAdapter.errorMergePolicyType
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let setupVals = self.coreData.setup()
        coreDataValueLabel.text = setupVals.0
        context1TextField.text = setupVals.1
        context2TextField.text = setupVals.2
    }
    
    /// Helper method to update main info label
    func updateCoreDataValueLabel() {
        coreData.updateControl { [weak self] (text) in
            self?.coreDataValueLabel.text = text
        }
    }
    
    /// change selected merge policy and update UI
    @IBAction func mergePolicyButtonAction(_ sender: UIButton) {
        let option = sender.tag
        
        let currButton = self.mergePolicyButtons[currMergePolicy.rawValue]
        currButton.backgroundColor = .white
        currButton.setTitleColor(currButton.tintColor, for: .normal)
        
        let selectedButton = self.mergePolicyButtons[option]
        selectedButton.backgroundColor = selectedButton.tintColor
        selectedButton.setTitleColor(.white, for: .normal)
        
        currMergePolicy = MergePolicyAdapter(rawValue: option)!
        coreData.setMergePolicy(currMergePolicy)
    }
    
    /// save only the first context; update UI
    @IBAction func context1SaveAction(_ sender: Any) {
        guard let text = context1TextField.text, text.isEmpty == false else { return }
        coreData.saveToContext1(text)
        self.updateCoreDataValueLabel()
    }
    
    /// save only the second context; update UI
    @IBAction func context2SaveAction(_ sender: Any) {
        guard let text = context2TextField.text, text.isEmpty == false else { return }
        coreData.saveToContext2(text)
        self.updateCoreDataValueLabel()
    }
    
    
    /// save both contexts, starting with the first one; update UI
    @IBAction func saveBothAction(_ sender: Any) {
        guard let text1 = context1TextField.text, text1.isEmpty == false else { return }
        guard let text2 = context2TextField.text, text2.isEmpty == false else { return }
        coreData.saveToContext1(text1)
        coreData.saveToContext2(text2)
        self.updateCoreDataValueLabel()
    }
    
    
}

