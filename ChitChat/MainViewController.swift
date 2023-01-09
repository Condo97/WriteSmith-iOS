//
//  MainViewController.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/8/23.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputTextView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        updateInputTextViewSize(textView: inputTextView)
    }
    
    @IBAction func submitButton(_ sender: Any) {
        ChatStorageHelper.appendChat(chatObject: ChatObject(text: inputTextView.text, userSent: .user))
        HTTPSHelper.getChatSonicTest(delegate: self, inputText: inputTextView.text)
        
        tableView.insertRows(at: [IndexPath(row: ChatStorageHelper.getAllChats().count - 1, section: 0)], with: .automatic)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}

//TODO: - Native implementation
extension UILabel {
    func setTextWithTypeAnimation(typedText: String, characterDelay: TimeInterval = 5.0) {
        text = ""
        var writingTask: DispatchWorkItem?
        writingTask = DispatchWorkItem { [weak weakSelf = self] in
            for character in typedText {
                DispatchQueue.main.async {
                    weakSelf?.text!.append(character)
                }
                Thread.sleep(forTimeInterval: characterDelay/100)
            }
        }
        
        if let task = writingTask {
            let queue = DispatchQueue(label: "typespeed", qos: DispatchQoS.userInteractive)
            queue.asyncAfter(deadline: .now() + 0.05, execute: task)
        }
    }
}

extension MainViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        updateInputTextViewSize(textView: textView)
        
    }
    
    func updateInputTextViewSize(textView: UITextView) {
        let size = CGSize(width: textView.frame.size.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        guard textView.contentSize.height < 70.0 else { textView.isScrollEnabled = true; return }
        
        textView.isScrollEnabled = false
        textView.constraints.forEach{ (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChatStorageHelper.getAllChats().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! ChatTableViewCell
        
        let finalText = ChatStorageHelper.getAllChats()[indexPath.row].text
        
        cell.chatText.text = ""
        var writingTask: DispatchWorkItem?
        writingTask = DispatchWorkItem { () in
            for character in finalText {
                DispatchQueue.main.async {
                    tableView.beginUpdates()
                    cell.chatText.text!.append(character)
                    tableView.endUpdates()
                }
                Thread.sleep(forTimeInterval: 5.0/100)
            }
        }
        
        if let task = writingTask {
            let queue = DispatchQueue(label: "typespeed", qos: DispatchQoS.userInteractive)
            queue.asyncAfter(deadline: .now() + 0.05, execute: task)
        }
        
//        cell.chatText.setTextWithTypeAnimation(typedText: "aldjflahsdljfhajklfhkljahdfkhasdjf hjkasdghfkjldljkfhajlsdfhk sdkfghkja dgfkjgasdjhfg aksdgf g sadfhg ajkhdfkad fkljh alkjdfljkahdfjk alsdkjfkl dafjkhdaljkfhkjahsdf klasdjfl h")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Show Chat Messages
        
    }
}

extension MainViewController: HTTPSHelperDelegate {
    func didGetChatSonicTest(json: [String : Any]) {
        guard let message = json["message"] as? String else {
            return
        }
        
        ChatStorageHelper.appendChat(chatObject: ChatObject(text: message, userSent: .ai))
        
        tableView.insertRows(at: [IndexPath(row: ChatStorageHelper.getAllChats().count - 1, section: 0)], with: .automatic)
    }
}
