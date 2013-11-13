//
//  DataModelController.h
//  BoxOfficePreview
//
//  Created by Ryan Cumley on 11/12/13.
//  Copyright (c) 2013 Ryan Cumley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModelController : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    NSMutableURLRequest* request;
    NSMutableData* receivedData;
}

@property (strong, nonatomic) NSMutableArray* movies;
@property (assign) id completionDelegate;

- (void)reloadRottenTomatoes;

@end

@protocol dataCompletionDelegate <NSObject>

- (void)modelSuccessfullyFetchedData:(NSMutableArray*)data;

@end
