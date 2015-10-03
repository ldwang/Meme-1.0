//
//  ViewController.swift
//  MemeMe 1.0
//
//  Created by Long Wang on 2015-09-27.
//  Copyright © 2015 Long Wang. All rights reserved.
//

import UIKit

struct Meme {
    var topText : String
    var bottomText : String
    var originalImage : UIImage
    var memedImage : UIImage
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var topTextField: UITextField!
    
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var tooBar: UIToolbar!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    //Define text field attributes with white color and black background
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName :   UIFont(name: "HelveticaNeue-CondensedBlack", size : 40)!,
        NSStrokeWidthAttributeName : -3.0
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup default Top Text field properties
        
        topTextField.text = "TOP"
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = .Center
        self.topTextField.delegate = self
        topTextField.tag = 0
        
        // Setup default Bottom Text field properties
        bottomTextField.text = "BOTTOM"
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.textAlignment = .Center
        self.bottomTextField.delegate = self
        //bottomTextField.clearsOnBeginEditing = true
        bottomTextField.tag = 1
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotifications()
        
        //Disable camera button if it's not supported
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        //Disable share button if the image is not chosen
        if imagePickerView.image == nil {
         shareButton.enabled = false
        } else {
            shareButton.enabled = true
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeToKeyboardNotifications()
    }
    
    @IBAction func shareMeme(sender: UIBarButtonItem) {
        //Create a memed image, pass it to the activity view controller.
        let image = generateMemedImage()
        let shareController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        //If the user completes an action in the activity view controller, save the meme to the shared storage
        shareController.completionWithItemsHandler = {
            activity, completed, items, error in
            if completed {
                self.saveMemedImage()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        self.presentViewController(shareController, animated: true, completion: nil)
    }
   
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self

        imagePicker.sourceType = .Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
        
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.contentMode = .ScaleAspectFit
            imagePickerView.image = image
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Text Field Delegate Methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
    //clear textField of default text.
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        // Set preset text if text field is empty. topTextField tag is 0, bottomTextField tag is 1
        if textField.text!.isEmpty && textField.tag == 0 {
            textField.text = "TOP"
        } else if textField.text!.isEmpty && textField.tag == 1 {
            textField.text = "BOTTOM"
        }
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func subscribeToKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self,selector: "keyboardWillShow:" , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,selector: "keyboardWillHide:" , name: UIKeyboardWillHideNotification, object: nil)
    }

    func unsubscribeToKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y += getKeyboardHeight(notification)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        if bottomTextField.editing {
            return keyboardSize.CGRectValue().height
        } else {
            return 0
        }
        
    }
    
    func saveMemedImage() {
        //Create the meme
        let meme = Meme( topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
        
        //TODO: Add to memes array in AppDelegate
        
    }
    
    func generateMemedImage() -> UIImage {
        //Hide toolbar and navbar
        self.tooBar.hidden = true
        self.navigationBar.hidden = true
        UIApplication.sharedApplication().statusBarHidden = true
        
        //render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Show toolbar and navbar
        self.tooBar.hidden = false
        self.navigationBar.hidden = false
        UIApplication.sharedApplication().statusBarHidden = false
        
        return memedImage
    }

}

