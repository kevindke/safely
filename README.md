# Safely

## Informing people about unsafe situations with real-time data.
 
In large cities like Seattle, there are many situations where people feel unsafe when travelling on foot, particularly at night.  While it’s difficult to provide assistance in time to someone who has the misfortune of falling victim to crime, Safely aims to preemptively inform users of dangerous situations before they enter physical proximity of the danger. 
 
The Safely app uses map-based visualizations of Seattle Police Department crime logs to display historical data (as a heatmap) and recent data (as interactive tips).  Safely users can also submit their own crime tips to be visualized on the map, creating geofenced radii of the incident. Other Safely users will receive a push notification upon entry. Overall, the Safely system keeps users vigilant of threats in a more time-sensitive manner than other forms of communication in the city. 

- [**List of Functionalities**](https://github.com/kevindke/safely#list-of-functionalities)  
- [**List of Contents**](https://github.com/kevindke/safely#list-of-contents)  
- [**Summary of Major Technology Decisions**](https://github.com/kevindke/safely#summary-of-major-technology-decisions)  
- [**Contact Information**](https://github.com/kevindke/safely#contact-information)  
- [**Video**](https://github.com/kevindke/safely#video-clip-showing-project-in-action)  

##

### List of Functionalities

A heat map of historical data (up to a year ago) are depicted in varied opacity in teal. The more opaque an area is, the more frequently crime has occurred there in the past year.
 
911 calls recorded in the past 72 hours are shown as red tips with different icons depicting categories of crime - cautionary/disturbances, assault/harassment/sex offense, theft/burglary/robbery, suspicious activity/lewd conduct, casualties/injuries, and gun/weapon calls.
 
Search for locations by address or landmark and view the current and historical crime conditions of that area.
 
Add a tip to the map by setting the location, radius (for the geofence), offense type,  and a short description. Other Safely users will receive a push notification about the crime if they enter the radius set around the incident.
 
### List of Contents
 
**Seattle.gpx**  
GPS exchange format file for running Seattle coordinates through the Xcode simulator (if not testing on a phone)
 
**SODAKit files**  
From soda-swift, a native Swift library used to access Socrata OpenData servers (https://github.com/socrata/soda-swift), compatible with iOS 8+ and OS X 10.10+. These files allow you to pull data from the Seattle Police Department databases and run queries on datasets. 
 
Used and modified under the MIT license.
 
**Geotification.swift, AddGeotificationViewController.swift**  
From Geotification, a starter project by Ray Wenderlich, that allows the map tips to create geofences around the incident (which allows push notifications to be sent out to other people’s phones). (https://www.raywenderlich.com/136165/core-location-geofencing-tutorial). 
 
Used and modified under the MIT license.
 
**DropMenuButton.swift**  
The file used to customize the dropdown menu when the user is generating a new tip. Dropdown menu was created by Marcos Paulo Rodrigues (https://github.com/kirkbyo/Dropper)
 
Used and modified under the MIT license.  
 
**LaunchScreen.storyboard**  
Launch screen for the app.
 
**AppDelegate.swift**  
Handles the app’s active and inactive states and push notification behaviors.
 
**MapViewController.swift**  
Contains the code for the majority of Safely’s functionality. Pulls data from SPD, stores historical and recent crime data, plots data on the map, and allows users to add tips.
 
**LocationSearchTable.swift**  
This is responsible for the search bar in the app that allows users to look up addresses or landmarks. From ThornTechPublic’s MapKitTutorial, used and adapted under the MIT license.
 
**Utilities.swift**   
Contains helper methods for the UI controller of the map (e.g. zooming).
 
**Images**  
All images needed for the UI are included in this folder of assets.
 
    
### Summary of Major Technology Decisions
Our technology stack was largely decided upon based on our user research and our team’s collective development experience. 
 
**Native toolkit:** Apple XCode 8 (iOS)  
**Frameworks:** MapKit & CoreLocation  
**Language:** Swift 3  
**Libraries:** soda-swift  
**Backend:** Firebase, Socrata  
 
**_Data-Visualization Focus_**  
In the process of designing and developing Safely, our focus shifted from producing an app that served as a safety-conscious mapping application to that of a mobile-first geographic data visualization.  This change came about as a result of user testing indicating that a sizable portion of Safely’s userbase would likely interact with Safely only to explore the data prior to using an existing “Triple A” mapping application such as Google Maps.  This gave the team freedom from some of the features that other libraries could offer and allowed us to focus on core functionality which could be found in the resources we ultimately utilized.
 
**_iOS MapKit & CoreLocation Frameworks_**  
Nearly all of our surveyed user base were iPhone users, so developing for iOS was a priority. Safely is built natively using iOS’s MapKit and CoreLocation frameworks which provided us the opportunity to get more support from existing Apple Developer documentation. 
 
**_Geofencing_**  
While the map interface is not as minimal as we originally intended, we sacrificed some user interface customizability in order to take advantage of MapKit’s well-documented and well-supported framework. This included the geofencing capabilities that significantly improved the value proposition of our app. 
 
**_Adapting & Modifying existing projects_**  
Due to the time constraints of our project, it was the most time and cost effective for us to build upon pre-existing open source projects that contained functionality we were looking to implement in our final project. Geotifications, Dropdown Menu, and LocationSearch allowed us to pick out existing UI map functionalities and customize them in a way that worked best for our app’s functionality. In addition, working with pre-existing code and reading tutorials and documentation on how to implement these features was very helpful for our team, who had very minimal experience coding in Swift 3 at the beginning of our project.
 
 
### Contact Information
Justine Edrozo  /  Designer & Developer  /  justineedrozo@gmail.com  
Kevin Ke  /  Designer & Developer  /  kevinkdke@gmail.com  
Brooks Lobe  /  Data Analyst  /  brooks.lobe@gmail.com  
Adrian Pacheco  /  Designer  /  adrianpacheco95@gmail.com  
 
### Video Clip Showing Project in Action
 
https://drive.google.com/open?id=0B9ejwWRyKbWhUi1FdnhnNldHSE0
