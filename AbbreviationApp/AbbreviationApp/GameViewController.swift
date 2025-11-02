//
//  GameViewController.swift
//  AbbreviationApp
//
//  Created by Papneja, Brajmohan on 22/08/19.
//  Copyright © 2019 Papneja, Brajmohan. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    enum GamePlay {
        case start
        case resume
        case inprogress
        case ended
    }
    
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var shortAcronym: UILabel!
    @IBOutlet weak var resultLabel : UILabel!
    @IBOutlet weak var scoreLabel :UILabel!
    @IBOutlet weak var attemptsLabel: UILabel!
    
    @IBOutlet weak var nextButton : UIButton!
    
    @IBOutlet weak var resultImage : UIImageView!
    
    @IBOutlet weak var acronymTextField: UITextField!
    
    var countAcronyms : Int = 0
    var score : Int = 0
    var attempts : Int = 1
    var checkCount : Int = 0
    var responseAcronyms : Array<Any>?
    var randomGeneratedAcronym : Dictionary<String,String>?
    var shortForm : String?
    var longFrom : String?
    
    var timer: Timer?
    var totalTime = 60
    var gameState = GamePlay.inprogress
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.title = "Play Acronym Game"
        AcronymServices.shared.getAllAcronyms(successBlock: { [weak self] response in
            print("response=\(String(describing: response))")
            
            guard let response = response as? Array<Any> else { return }
            self?.countAcronyms = response.count as Int
            self?.responseAcronyms = response
            
            self?.setNewGame()
            
            DispatchQueue.main.async {
                self?.startTimer()
            }
        }) { error in
            print("error=\(String(describing: error))")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopTimer()
    }
    
    private func startTimer() {
        self.totalTime = 60
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    func stopTimer(){
        self.timer?.invalidate()
        self.timer = nil
    }
    
    @objc func updateTimer() {
        print(self.totalTime)
        self.lblTimer.text = self.timeFormatted(self.totalTime) // will show timer
        
        if totalTime != 0 {
            totalTime -= 1  // decrease counter timer
        }
        else {
            gameOver(reason: "Time Over")
        }
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds
        return String(format: "%02d", seconds)
    }
    
    fileprivate func gameOver(reason: String) {
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
            let alert = UIAlertController(title: "Game Over: \(reason)", message: "It's recommended you go through the acronym list.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    fileprivate func setNewGame() {
        resetResultDisplay()
        let randomInt:Int = Int.random(in: 1..<(self.countAcronyms ))
        
        guard let responseAcronyms = self.responseAcronyms else {return}
        
        guard let randomGeneratedAcronym = responseAcronyms[randomInt] as? Dictionary<String,String> else{return}
        
        self.shortForm = randomGeneratedAcronym["short"]
        self.longFrom = randomGeneratedAcronym["long"]
        
        DispatchQueue.main.async {
            self.shortAcronym.text =   self.shortForm
        }
    }
    
    func updateGameState()
    {
        checkCount += 1
        if(checkCount > 5) {gameState = .ended}
    }
    
    fileprivate func resetResultDisplay() {
        
        DispatchQueue.main.async {
        self.resultImage.image = nil
        self.resultLabel.text = ""
        self.resultImage.isHidden = true
        self.resultLabel.isHidden = true
        }
    }
    
    
    @IBAction func checkResult () {
        updateGameState()
        
        if (gameState == .ended) {
            gameOver(reason: "Maximum checks crossed")
            return
        }
        
        let text: String = acronymTextField.text ?? ""
        var result : Bool = false
        result = iterateAllAcronyms(text)
        
        print("testing")
        self.resultImage.isHidden = false
        self.resultLabel.isHidden = false
        
        if result {
            self.resultImage.image = UIImage(named: "correct")
            self.resultLabel.text = "correct"
            
        } else {
            self.resultImage.image = UIImage(named: "wrong")
            self.resultLabel.text = "correct"
        }
        self.scoreLabel.text = "\(score)"
    }
    
    fileprivate func iterateAllAcronyms(_ text: String) -> Bool {
        var result = false
        
        guard let responseAcronyms = responseAcronyms else {return false}
        for dict in responseAcronyms
        {
            guard let localDict : Dictionary = dict as? Dictionary<String,String> else {break}
            print(localDict)
            
            if let val = localDict["short"] {
                // now val is not nil and the Optional has been unwrapped, so use it
                if let short = self.shortForm, let long = self.longFrom {
                    if (val.caseInsensitiveCompare(short) == ComparisonResult.orderedSame) && (text.caseInsensitiveCompare(long) == ComparisonResult.orderedSame) {
                        result = true
                        if !(self.resultLabel.text == "correct"){
                            score += 1
                        }
                    }
                }
                
            }
        }
        
        return result
    }
            
            
    fileprivate func blinkAttemptsLabel() {
        self.attemptsLabel.alpha = 1

        UIView.animate(withDuration: 0.7, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.attemptsLabel.alpha = 0
        }, completion: nil)
        
        UIView.animate(withDuration: 0.7, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.attemptsLabel.alpha = 1
        }, completion: nil)
    }
    
    fileprivate func updateAttempts() {
        attempts += 1
        blinkAttemptsLabel()
        self.attemptsLabel.text = "\(attempts)/3"
        if(attempts == 3){
            self.nextButton.isHidden = true
        }
    }
    
    @IBAction func nextAttempt () {
        self.acronymTextField.text = ""
        setNewGame()
        updateAttempts()
        
    }
 }
