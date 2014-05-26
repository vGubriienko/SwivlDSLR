/*
 *  AVSandboxNotifications.h
 *  AVSandbox
 *
 *  Notifications used throughout the AVSandbox application
 *
 *  Created by Geoff Chatterton on 9/30/11.
 *  Copyright 2011 Duff Research LLC. All rights reserved.
 *
 */


extern NSString* AVSandboxLibraryChangedNotification;   // something was saved/deleted/modified in the local library
extern NSString* AVSandboxRecordingStoppedNotification; // Recording stopped for some reason (user, error, etc.)
extern NSString* AVSandboxRecordingSafeToExitNotification;  // Recording stopped, video file saved, thumbnails created
extern NSString* AVSandboxRecordingStartedNotification; // Recording has started
extern NSString* AVSandboxApplicationActiveNotification;// Called when app enters foreground and becomes active
extern NSString* AVSandboxSwivlDockAttached;
extern NSString* AVSandboxSwivlDockDetached;
extern NSString* AVSandboxMarkerBatteryLevelChanged;
extern NSString* AVSandboxBaseBatteryLevelChanged;
extern NSString* AVSandboxNavToFromRecordingScreen; // to keep the SwivlManager state machine on track
// Object is bool value (YES for entering recording screen)
extern NSString* AVSandboxTrackingStateChangedNotification; // to update the app; check
extern NSString* AVSandboxFastTrackingEnabledStateChangedNotification; // to update the dock
extern NSString* AVSandboxPanningStateChangedNotification; // to update the app; check

extern NSString* AVSandboxSwivlScriptStateChangedNotification;
extern NSString* AVSandboxScriptProgressNeedStartNotification;
extern NSString* AVSandboxScriptProgressDidFinishNotification;
