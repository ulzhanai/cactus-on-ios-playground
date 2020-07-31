
//: Playground - noun: a place where people can play
import PlaygroundSupport
import Foundation
PlaygroundPage.current.needsIndefiniteExecution = true

class CoinsBalance{
    static let balance = CoinsBalance()
    
    var resultingBalance = 0
    
    func addCoins(coins: Int) {
        resultingBalance += coins
    }
    
    func printBalance(){
        print("Current balance is")
            print(resultingBalance)
    }
    
}

class Session {
    let durationInSeconds: Int
    
    init(durationInSeconds: Int) {
        self.durationInSeconds = durationInSeconds
    }
}

protocol SessionManagerDelegate {
    func showSessionStarted()
    func showTimeLeft(secondsLeft: Int)
    func showSessionEnded()
    func showUserCancelledSession()
    func userCancelledSession()
}

class SessionManager {
    var sessionDelegate: SessionManagerDelegate
    var timer: Timer?
    let sessionStorage = SessionsStorage()
    
    init(sessionDelegate: SessionManagerDelegate) {
        self.sessionDelegate = sessionDelegate
    }
    
    func startSession(session: Session) {
        sessionDelegate.showSessionStarted()
        sessionDelegate.showTimeLeft(secondsLeft: session.durationInSeconds)
        
        var secondsLeft = session.durationInSeconds

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            secondsLeft -= 1
            self.sessionDelegate.showTimeLeft(secondsLeft: secondsLeft)
            
            if secondsLeft == 0 {
                SessionsStorage.shared.add(session: session)
                
                if session.durationInSeconds<=30{
                    CoinsBalance.balance.addCoins(coins: 3)
                
                } else{
                
                    if session.durationInSeconds<=60{
                        CoinsBalance.balance.addCoins(coins: 6)
                    } else {
                        CoinsBalance.balance.addCoins(coins: 9)
                    }
                    
                }
                
                CoinsBalance.balance.printBalance()
                
                self.sessionDelegate.showSessionEnded()
                
                self.timer?.invalidate()
                self.timer = nil
            }
        }
    }
    
    func cancelSession(){
        sessionDelegate.showUserCancelledSession()
        self.timer?.invalidate()
        self.timer = nil
    }
}

class SessionsStorage {
    static let shared = SessionsStorage()
    
    var sessions = [Session]()
    
    func add(session: Session) {
        sessions.append(session)
    }
}


class SessionView: SessionManagerDelegate {
    var sessionManager: SessionManager?
    
    func userDidStartSession(durationInSeconds: Int) {
        sessionManager?.startSession(session: Session(durationInSeconds: durationInSeconds))
    }
    
    func showSessionStarted() {
        print("sessionStarted")
    }
    
    func showTimeLeft(secondsLeft: Int) {
        print("\(secondsLeft)")
    }
    
    func showSessionEnded() {
        print("sessionEnded")
    }
    
    func userCancelledSession(){
        sessionManager?.cancelSession()
        
    }
    
    func showUserCancelledSession(){
        print("sessionCancelled")
    }
}


///Break stuff


class Break {
    let durationInSeconds: Int
    
    init(durationInSeconds: Int) {
        self.durationInSeconds = durationInSeconds
    }
}


protocol BreakManagerDelegate {
    func showBreakStarted()
    func showTimeLeft(secondsLeft: Int)
    func showBreakEnded()
}

class BreakManager {
    var breakDelegate: BreakManagerDelegate
    var timer: Timer?
    
    init(breakDelegate: BreakManagerDelegate) {
        self.breakDelegate = breakDelegate
    }
    
    func startBreak(breakInst: Break) {
        breakDelegate.showBreakStarted()
        breakDelegate.showTimeLeft(secondsLeft: breakInst.durationInSeconds)
        
        var secondsLeft = breakInst.durationInSeconds
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            secondsLeft -= 1
            self.breakDelegate.showTimeLeft(secondsLeft: secondsLeft)
            
            if secondsLeft == 0 {
                self.breakDelegate.showBreakEnded()
                self.timer?.invalidate()
                self.timer = nil
            }
        }
    }
}


class BreakView: BreakManagerDelegate {
    var breakManager: BreakManager?
    
    func userStartedBreak(durationInSeconds: Int) {
        breakManager?.startBreak(breakInst: Break(durationInSeconds: durationInSeconds))
    }
    
    func showBreakStarted() {
        print("break started")
    }
    
    func showTimeLeft(secondsLeft: Int) {
        print("\(secondsLeft)")
    }
    
    func showBreakEnded() {
        print("break ended")
    }
}

// using DispatchQueue.main.asyncAfter for pausing, so that all three functions are not called at the same time.

//Testing Task 1: cancell session
let sessionView = SessionView()
sessionView.sessionManager = SessionManager(sessionDelegate: sessionView)

sessionView.userDidStartSession(durationInSeconds: 10)

DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
  sessionView.userCancelledSession()
}

// Testing Task 2: break
let breakView = BreakView()
breakView.breakManager = BreakManager(breakDelegate: breakView)

DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) {
    breakView.userStartedBreak(durationInSeconds: 5)
}

//Testing Task 3: Show Balance
let sessionView1 = SessionView()
sessionView1.sessionManager = SessionManager(sessionDelegate: sessionView)

DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
    sessionView1.userDidStartSession(durationInSeconds: 3)
}

let sessionView2 = SessionView()
sessionView2.sessionManager = SessionManager(sessionDelegate: sessionView)

DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(13)) {
    sessionView2.userDidStartSession(durationInSeconds: 3)
}



