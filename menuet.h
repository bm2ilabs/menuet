#ifndef __MENUET_H__
#define __MENUET_H__

#import <Cocoa/Cocoa.h>
#import <UserNotifications/UserNotifications.h>

void setState(const char *jsonString);
void menuChanged();
void createAndRunApplication();
void requestNotificationPermission(void (*callback)(bool granted, void* data), void* data);

#endif