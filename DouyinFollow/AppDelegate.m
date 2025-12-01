//
//  AppDelegate.m
//  DouyinFollow
//
//  Created by 吴桐 on 2025/11/20.
//

#import "AppDelegate.h"
#import "SDWebImage/SDWebImage.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"启动%@", [NSDate date]);
  SDImageCacheConfig *config = [SDImageCache sharedImageCache].config;

      //内存缓存上限，50MB
      config.maxMemoryCost = 50 * 1024 * 1024;
      //磁盘缓存上限，200MB
      config.maxDiskSize = 200 * 1024 * 1024;
      //磁盘缓存有效期（秒），例如一周
      config.maxDiskAge = 7 * 24 * 60 * 60;
      return YES;
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
  // Called when a new scene session is being created.
  // Use this method to select a configuration to create the new scene with.
  return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
  // Called when the user discards a scene session.
  // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
  // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
