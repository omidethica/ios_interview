# Avicenna 3rd Interview - Software Development Engineer (iOS Application)

## Description
You are given an iOS application that only has one ViewController and collects GPS signals periodically. **This application is supposed to stay active/live all the time to collect the GPS data**. In this application, the `ViewController.swift` class is responsible for handling periodic cycles of data collection, in which in this case there are two: GPS and motion-based activity recognition data. The `LocationManager.swift` class is responsible for GPS data collection and the `MotionBasedActivityRecognition.swift` class is responsible for collecting and detecting user’s motion-based activities and their types, such as stationary, walking, running, and etc. The `MotionActivityTypes.swift` class shows all different types of activities that are detectable in this application. Other classes are implemented to support the functionality of these two classes.

## Assumptions
- You can assume that the user grants required location permission to the application if needed.
- You can assume that all the collected data are saved in a local database and you can use provided class methods to retrieve them.
- The application is supposed to stay active in the background all the time. 
- You can assume that required background mode keys are added to the application.

## Problem
GPS data collection is a resource-consuming process and actively collecting GPS signals significantly impacts battery life. Currently, some mechanisms are implemented to decrease the impact of the data collection on the battery, however, more optimization is required. As a programmer, **you are required to suggest a solution to optimize this application further to increase battery life**. You are welcome to use other classes in the application as part of your solution or offer new ways to fix this problem. While implementing your solution, feel free to refactor classes or fix potential bugs if needed.

The acceptable solution shall meet the following requirements:
- The solution should be implemented in a separate branch and in a single commit.
- The commit message should describe the content of the patch and should not exceed 70 characters
- A new merge request should be created and submitted for review.

## Code Style
- The line length limit is 120 characters
- We use spaces instead of tabs

