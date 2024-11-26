//
//  RealmActivityHistory.swift
//  Ethica
//
//  Created by amin tavassolian on 2018-06-19.
//  Copyright © 2018 EthicaDataServices. All rights reserved.
//

import CoreMotion

protocol MotionBasedActivityRecognitionProtocol {
    func getActivityRecognitionUpdates()
    func saveActivities(activityData: [CMMotionActivity])
    func isUserStationary() -> Bool
    func saveActivityHistory(activity: MotionBasedActivity)
    func resetActivityHistory()
    func readActivityHistory(minLength: Double,
                                    minConfidence: Int) -> [MotionBasedActivity]
}

final class MotionBasedActivityRecognition: MotionBasedActivityRecognitionProtocol {
    private static let MIN_ACCEPTABLE_CONFIDENCE_LEVEL: Int = CMMotionActivityConfidence.high.rawValue
    private static let MIN_ACCEPTABLE_ACTIVITY_PERIOD_IN_S: Double = 150

    private static let INVALID_TIME_STAMP: Int64 = 0
    private static let INVALID_ACTIVITY_LENGTH: Double = 0
    private static let INVALID_ACTIVITY_TYPE: Int = -1
    private static let INVALID_CONFIDENE_LEVEL: Int = MotionActivityConfidenceLevel.UNKNOWN.rawValue

    @objc dynamic var activityType: Int = INVALID_ACTIVITY_TYPE
    @objc dynamic var startTimeStamp: Int64 = INVALID_TIME_STAMP
    @objc dynamic var confidenceLevel: Int = INVALID_CONFIDENE_LEVEL
    @objc dynamic var lengthInSec: Double = INVALID_ACTIVITY_LENGTH

    private static var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "core_motion_ops"
        return queue
    }()


   static var activityManager = CMMotionActivityManager()

    init() {

    }

    func getActivityRecognitionUpdates() {
        if CMMotionActivityManager.isActivityAvailable() {
            let fromDate = Date.init(timeIntervalSinceNow: -1 * ViewController.TIME_BETWEEN_SCANS)
            let toDate = Date()
            MotionBasedActivityRecognition.activityManager
                .queryActivityStarting(from: fromDate,
                                       to: toDate,
                                       to: MotionBasedActivityRecognition.operationQueue) { (activityData, error) in

                guard error == nil else {
                    MotionBasedActivityRecognition.activityManager.stopActivityUpdates()
                    return
                }

                guard let activityData = activityData else {
                    MotionBasedActivityRecognition.activityManager.stopActivityUpdates()
                    return
                }

                guard activityData.count > 0 else {
                    MotionBasedActivityRecognition.activityManager.stopActivityUpdates()
                    return
                }

                // Save all the activities. You can assume all the activities are saved in DB here.

                    MotionBasedActivityRecognition.activityManager.stopActivityUpdates()
            }
        }
    }


    func saveActivities(activityData: [CMMotionActivity]) {
        resetActivityHistory()

        let currentTimeStamp = Date().timeIntervalSince1970

        for i in 0 ..< activityData.count {
            let activity = activityData[i]
            var activityType: Int?
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


            guard activity.confidence.rawValue >= MotionBasedActivityRecognition.MIN_ACCEPTABLE_CONFIDENCE_LEVEL else {
                return
            }

            confidence = activity.confidence.rawValue
            activityLength = ((i < activityData.count - 1)
                ? activityData[i+1].startDate.timeIntervalSince1970
                : currentTimeStamp) - activity.startDate.timeIntervalSince1970

            guard let aType = activityType, let aLength = activityLength, let conf =  confidence else { return }
            let activityToSave = MotionBasedActivity(startTimeStamp: activity.startDate.millisecondsSince1970,
                                                 activityType: aType,
                                                 lengthInSec: aLength,
                                                 confidence: conf)

            saveActivityHistory(activity: activityToSave)
        }
    }

    // This function checks recorded activities, if there is at least one.
    // If all of recorded activites indicate that the user is stationary,
    // then the function reports user as stationary”
    func isUserStationary() -> Bool {
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

    func saveActivityHistory(activity: MotionBasedActivity) {
        // This function saves the activity history
    }

    func resetActivityHistory() {
        // This function removes the history of the collected activities
    }

    func readActivityHistory(minLength: Double = 0,
                                    minConfidence: Int = 0) -> [MotionBasedActivity] {
        //This function returns the history of the collected activities
        return [MotionBasedActivity]()
    }
}

extension Date {
    var millisecondsSince1970: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0))
    }
}

struct MotionBasedActivity {
    let startTimeStamp: Int64?
    let activityType: Int?
    let lengthInSec: Double?
    let confidence: Int?
}
