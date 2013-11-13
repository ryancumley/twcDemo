//
//  AppDelegate.h
//  BoxOfficePreview
//
//  Created by Ryan Cumley on 11/12/13.
//  Copyright (c) 2013 Ryan Cumley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    NSMutableURLRequest* request;
    NSMutableData* receivedData;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableArray* movies;
@property (assign) id fetchedDataDelegate;

@end

@protocol completedFetch <NSObject>

- (void)fetchCompletedWithData:(NSMutableArray*)data;

@end
