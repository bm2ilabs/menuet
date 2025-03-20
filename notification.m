#import <Cocoa/Cocoa.h>
#import <UserNotifications/UserNotifications.h>
#import "notification.h"

void showNotification(const char *jsonString) {
    NSDictionary *jsonDict = [NSJSONSerialization
                            JSONObjectWithData:[[NSString stringWithUTF8String:jsonString]
                                            dataUsingEncoding:NSUTF8StringEncoding]
                            options:0
                            error:nil];

    // Create notification content
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = jsonDict[@"Title"] ?: @"";
    content.subtitle = jsonDict[@"Subtitle"] ?: @"";
    content.body = jsonDict[@"Message"] ?: @"";
    content.sound = [UNNotificationSound defaultSound];

    NSString *identifier = jsonDict[@"Identifier"];
    if (!identifier || identifier.length == 0) {
        identifier = [[NSUUID UUID] UUIDString];
    }

    // Set up actions if needed
    NSMutableArray *actions = [NSMutableArray array];

    NSString *actionButton = jsonDict[@"ActionButton"];
    if (actionButton.length > 0) {
        UNNotificationAction *action = [UNNotificationAction
                                     actionWithIdentifier:@"ACTION_BUTTON"
                                     title:actionButton
                                     options:UNNotificationActionOptionForeground];
        [actions addObject:action];
    }

    NSString *responsePlaceholder = jsonDict[@"ResponsePlaceholder"];
    if (responsePlaceholder.length > 0) {
        UNTextInputNotificationAction *textAction = [UNTextInputNotificationAction
                                                 actionWithIdentifier:@"TEXT_REPLY"
                                                 title:@"Reply"
                                                 options:UNNotificationActionOptionNone
                                                 textInputButtonTitle:@"Send"
                                                 textInputPlaceholder:responsePlaceholder];
        [actions addObject:textAction];
    }

    // Create category for actions if needed
    if (actions.count > 0) {
        NSString *categoryId = [NSString stringWithFormat:@"CATEGORY_%@", identifier];
        UNNotificationCategory *category = [UNNotificationCategory
                                         categoryWithIdentifier:categoryId
                                         actions:actions
                                         intentIdentifiers:@[]
                                         options:UNNotificationCategoryOptionNone];

        [[UNUserNotificationCenter currentNotificationCenter]
            setNotificationCategories:[NSSet setWithObject:category]];

        content.categoryIdentifier = categoryId;
    }

    // Create trigger for immediate display
    UNNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger
                                   triggerWithTimeInterval:0.1
                                   repeats:NO];

    // Create the request
    UNNotificationRequest *request = [UNNotificationRequest
                                   requestWithIdentifier:identifier
                                   content:content
                                   trigger:trigger];

    // Add the request to the notification center
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UNUserNotificationCenter currentNotificationCenter]
            addNotificationRequest:request
            withCompletionHandler:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"Error showing notification: %@", error);
                }

                // Handle removal if needed
                BOOL removeFromNotificationCenter = [jsonDict[@"RemoveFromNotificationCenter"] boolValue];
                if (removeFromNotificationCenter) {
                    [[UNUserNotificationCenter currentNotificationCenter]
                        removeDeliveredNotificationsWithIdentifiers:@[identifier]];
                }
            }];
    });
}