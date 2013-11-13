//
//  DataModelController.m
//  BoxOfficePreview
//
//  Created by Ryan Cumley on 11/12/13.
//  Copyright (c) 2013 Ryan Cumley. All rights reserved.
//

#import "DataModelController.h"

@implementation DataModelController

- (void)reloadRottenTomatoes {
    [self configureUrlRequest];
    if (request) {
        [self makeRequest];
    }
}

- (BOOL)configureUrlRequest {
    NSString* url = @"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=s9gd3xzejzsyjzrj5zfu3d6a";
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod: @"GET"];
    
    return YES;//could add some error handling in here to return a NO later.
}

- (BOOL)makeRequest {
    if (!request) {
        return NO; //Fail quickly if the request has not been configured
    }
    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    if (connection) {
        receivedData = [NSMutableData data];
       	[receivedData setLength: 0];
    }
    else {
        return NO;
    }
    
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //not much reason to believe we care about individual responses for a data fetch this small.
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self parseData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //if we wanted to inform the user of this development, here's where we'd get the signal to commence. Currently just a breakpoint dump
}


- (void)parseData {
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:receivedData options:kNilOptions error:&error];
    if (error) {
        NSLog(@"error: %@",error.description);
    }
    _movies = [[NSMutableArray alloc] init];
    _movies = [json objectForKey:@"movies"];
    
    [self.completionDelegate modelSuccessfullyFetchedData:_movies];
    
}

@end
