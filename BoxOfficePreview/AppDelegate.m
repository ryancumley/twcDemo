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
    // Override point for customization after application launch.
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
    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    if (connection) {
        receivedData = [NSMutableData data];
       	[receivedData setLength: 0];
    }
    else {
        NSLog(@"failed to Connect");
    }
    
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response

{
    
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data

{
    
	[receivedData appendData:data];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection

{
	NSLog(@"Succeeded! Received %d bytes of data", [receivedData length]);
    [self parseData];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error

{
    
	NSLog(@"Connection failed! Error - %@ %@",
          
          [error localizedDescription],
          
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
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
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
