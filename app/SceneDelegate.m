//
//  SceneDelegate.m
//  iSH
//
//  Created by Theodore Dubois on 10/26/19.
//

#import "AppDelegate.h"
#import "SceneDelegate.h"
#import "AboutViewController.h"

TerminalViewController *currentTerminalViewController = NULL;

@interface SceneDelegate ()

@property NSString *terminalUUID;

@end

static NSString *const TerminalUUID = @"TerminalUUID";

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if ([NSUserDefaults.standardUserDefaults boolForKey:@"recovery"]) {
        UINavigationController *vc = [[UIStoryboard storyboardWithName:@"About" bundle:nil] instantiateInitialViewController];
        AboutViewController *avc = (AboutViewController *) vc.topViewController;
        avc.recoveryMode = YES;
        self.window.rootViewController = vc;
        return;
    }
    
    UITabBarController *tbc = (UITabBarController *) self.window.rootViewController;
    TerminalViewController *vc = (TerminalViewController *)tbc.viewControllers[terminalIndex];

    vc.sceneSession = session;
    if (session.stateRestorationActivity == nil) {
        [vc startNewSession];
    } else {
        self.terminalUUID = session.stateRestorationActivity.userInfo[TerminalUUID];
        [vc reconnectSessionFromTerminalUUID:
         [[NSUUID alloc] initWithUUIDString:self.terminalUUID]];
    }
}

- (NSUserActivity *)stateRestorationActivityForScene:(UIScene *)scene {
    NSUserActivity *activity = [[NSUserActivity alloc] initWithActivityType:@"app.ish.scene"];
    UITabBarController *tbc = (UITabBarController *) self.window.rootViewController;
    TerminalViewController *vc = (TerminalViewController *)tbc.viewControllers[terminalIndex];
    if ([vc isKindOfClass:TerminalViewController.class]) {
        self.terminalUUID = vc.sessionTerminalUUID.UUIDString;
        if (self.terminalUUID != nil) {
            [activity addUserInfoEntriesFromDictionary:@{TerminalUUID: self.terminalUUID}];
        }
    }
    return activity;
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
    UITabBarController *tbc = (UITabBarController *) self.window.rootViewController;
    TerminalViewController *terminalViewController = (TerminalViewController *)tbc.viewControllers[terminalIndex];
    currentTerminalViewController = terminalViewController;
}

- (void)sceneWillResignActive:(UIScene *)scene {
    UITabBarController *tbc = (UITabBarController *) self.window.rootViewController;
    TerminalViewController *terminalViewController = (TerminalViewController *)tbc.viewControllers[terminalIndex];
    if (currentTerminalViewController == terminalViewController) {
        currentTerminalViewController = NULL;
    }
}

@end
