//
//  AppDelegate.m
//  BoxOfficePreview
//
//  Created by Ryan Cumley on 11/12/13.
//  Copyright (c) 2013 Ryan Cumley. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    BOOL configured = [self configureUrlRequest];
    BOOL makeTheRequest = [self makeRequest];
    
    if (configured && makeTheRequest) {
        //no error handling purpose here at this stage, more refined implementation would handle errors here
    }
    return YES;
}


#pragma mark -
#pragma mark URL request and datadelegate handling methods

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
    
    ViewController* vc = (ViewController*)self.window.rootViewController; //using the storyboard identifier technique would be cleaner than having appDelegate have to know this class...
    [self setFetchedDataDelegate:vc.tvc];//notifies tableView whenever new fetch is complete
    [self.fetchedDataDelegate fetchCompletedWithData:_movies];
}




#pragma mark - 
#pragma mark iOS environment and app lifecycle
							
- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
