//
//  RealmActivityHistory.swift
//  Ethica
//
//  Created by amin tavassolian on 2018-06-19.
//  Copyright © 2018 EthicaDataServices. All rights reserved.
//

import CoreMotion

class MotionBasedActivityRecognition {
    static let MIN_ACCEPTABLE_CONFIDENCE_LEVEL: Int = CMMotionActivityConfidence.high.rawValue
    static let MIN_ACCEPTABLE_ACTIVITY_PERIOD_IN_S: Double = 150

    static let INVALID_TIME_STAMP: Int64 = 0
    static let INVALID_ACTIVITY_LENGTH: Double = 0
    static let INVALID_ACTIVITY_TYPE: Int = -1
    static let INVALID_CONFIDENE_LEVEL: Int = MotionActivityConfidenceLevel.UNKNOWN.rawValue

    @objc dynamic var activityType: Int = INVALID_ACTIVITY_TYPE
    @objc dynamic var startTimeStamp: Int64 = INVALID_TIME_STAMP
    @objc dynamic var confidenceLevel: Int = INVALID_CONFIDENE_LEVEL
    @objc dynamic var lengthInSec: Double = INVALID_ACTIVITY_LENGTH

    private static var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "core_motion_ops"
        return queue
    }()


    private static var activityManager = CMMotionActivityManager()

    init(startTimeStamp: Int64,
         activityType: Int,
         lengthInSec: Double,
         confidence: Int) {

        self.startTimeStamp = startTimeStamp
        self.lengthInSec = lengthInSec
        self.confidenceLevel = confidence
        self.activityType = activityType
    }

    static func getActivityRecognitionUpdates() {
        if CMMotionActivityManager.isActivityAvailable() {
            let fromDate = Date.init(timeIntervalSinceNow: -1 * ViewController.TIME_BETWEEN_SCANS)
            let toDate = Date()
            self.activityManager
                .queryActivityStarting(from: fromDate,
                                       to: toDate,
                                       to: self.operationQueue) { (activityData, error) in

                guard error == nil else {
                    self.activityManager.stopActivityUpdates()
                    return
                }

                guard let activityData = activityData else {
                    self.activityManager.stopActivityUpdates()
                    return
                }

                guard activityData.count > 0 else {
                    self.activityManager.stopActivityUpdates()
                    return
                }

                // Save all the activities. You can assume all the activities are saved in DB here.

                self.activityManager.stopActivityUpdates()
            }
        }
    }


    static func saveActivities(activityData: [CMMotionActivity]) {
        resetActivityHistory()

        let currentTimeStamp = Date().timeIntervalSince1970

        for i in 0 ..< activityData.count {
            let activity = activityData[i]
            let activityType: Int!
            let confidence: Int?
            let activityLength: Double?

            if activity.automotive {
                activityType = MotionActivityTypes.VEHICLE.rawValue
            } else if activity.cycling {
                activityType = MotionActivityTypes.BIKING.rawValue
            } else if activity.running {
                activityType = MotionActivityTypes.RUNNING.rawValue
            } else if activity.walking {
                activityType = MotionActivityTypes.WALKING.rawValue
            } else if activity.stationary {
                continue
            } else if activity.unknown {
                continue
            } else {
                continue
            }


            guard activity.confidence.rawValue < MotionBasedActivityRecognition.MIN_ACCEPTABLE_CONFIDENCE_LEVEL else {
                return
            }

            confidence = activity.confidence.rawValue
            activityLength = ((i < activityData.count - 1)
                ? activityData[i+1].startDate.timeIntervalSince1970
                : currentTimeStamp) - activity.startDate.timeIntervalSince1970

            let activityToSave = MotionBasedActivityRecognition(startTimeStamp: activity.startDate.millisecondsSince1970,
                                                 activityType: activityType!,
                                                 lengthInSec: activityLength!,
                                                 confidence: confidence!)

            saveActivityHistory(activity: activityToSave)
        }
    }

    // This function checks recorded activities, if there is at least one.
    // If all of recorded activites indicate that the user is stationary,
    // then the function reports user as stationary”
    static func isUserStationary() -> Bool {
        let savedActivities =
            readActivityHistory(
                minLength: MotionBasedActivityRecognition.MIN_ACCEPTABLE_ACTIVITY_PERIOD_IN_S,
                minConfidence: MotionBasedActivityRecognition.MIN_ACCEPTABLE_CONFIDENCE_LEVEL)
        
        guard savedActivities.count > 0 else {
            return false
        }

        var isStationary = true
        for activity in savedActivities {
            if activity.activityType != MotionActivityTypes.STILL.rawValue {
                isStationary = false
                break
            }
        }

        return isStationary
    }

    private static func saveActivityHistory(activity: MotionBasedActivityRecognition) {
        // This function saves the activity history
    }

    private static func resetActivityHistory() {
        // This function removes the history of the collected activities
    }

    private static func readActivityHistory(minLength: Double = 0,
                                    minConfidence: Int = 0) -> [MotionBasedActivityRecognition] {
        //This function returns the history of the collected activities
        return [MotionBasedActivityRecognition]()
    }
}

extension Date {
    var millisecondsSince1970: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0))
    }
}
