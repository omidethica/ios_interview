//
//  ViewController.swift
//  ios_interview
//
//  Created by amin tavassolian on 2021-01-14.
//

import UIKit

final class ViewController: UIViewController {

    static let TIME_PER_SCAN: TimeInterval = 60
    static let TIME_BETWEEN_SCANS: TimeInterval = 300
    private static var periodicScanningTimer: Timer!
    private static var performScanningTimer: Timer!
    private var readingActive = false
    private var motionBasedActivityRecognition: MotionBasedActivityRecognitionProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshStreams()
        motionBasedActivityRecognition = MotionBasedActivityRecognition()
    }

    private func refreshStreams() {
        self.stopAllScans()

        let result = LocationManager.getInstance().startUpdatingLocation(collectionType: .ALWAYS)
        guard result else {
            return
        }

        self.initializePeriodicScanningTimer()
    }

    private func stopAllScans() {
        self.readingActive = false

        if ViewController.performScanningTimer != nil {
            ViewController.performScanningTimer.invalidate()
        }

        if ViewController.periodicScanningTimer != nil {
            ViewController.periodicScanningTimer.invalidate()
        }

        // save all the recorded data.

        LocationManager.getInstance().stopUpdatingLocation()
    }

    fileprivate func initializePeriodicScanningTimer() {

        ViewController.periodicScanningTimer =
            Timer.scheduledTimer(timeInterval: ViewController.TIME_BETWEEN_SCANS,
                                 target: self,
                                 selector: #selector(self.initializePerformScanningTimer),
                                 userInfo: nil,
                                 repeats: true)
        ViewController.periodicScanningTimer.fire()
    }

    @objc fileprivate func initializePerformScanningTimer() {

            ViewController.performScanningTimer =
            Timer.scheduledTimer(timeInterval: ViewController.TIME_PER_SCAN,
                                 target: self,
                                 selector: #selector(self.scan),
                                 userInfo: nil,
                                 repeats: true)

            ViewController.performScanningTimer.fire()


    }

    @objc fileprivate func scan() {

        if !self.readingActive {
            self.readingActive = true
            guard let motionBasedActivity = motionBasedActivityRecognition else { return }
            motionBasedActivity.getActivityRecognitionUpdates()
            if !motionBasedActivity.isUserStationary() {
                LocationManager.getInstance().changeLocationAccuracy(newAccuracy: .BEST)
            } 

        } else {
            self.readingActive = false

            LocationManager.getInstance().changeLocationAccuracy(newAccuracy: .THREE_KILOMETERS)

            if ViewController.performScanningTimer != nil {
                ViewController.performScanningTimer.invalidate()
                ViewController.performScanningTimer = nil
            }
        }
    }

}

