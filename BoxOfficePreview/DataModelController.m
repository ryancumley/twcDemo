//
//  DataModelController.m
//  BoxOfficePreview
//
//  Created by Ryan Cumley on 11/12/13.
//  Copyright (c) 2013 Ryan Cumley. All rights reserved.
//

#import "DataModelController.h"
#import "AppDelegate.h"
#import "Movie.h"

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
    
    for (NSDictionary* movie in _movies) {
        NSString* title = [movie valueForKey:@"title"];
        BOOL exists = [self alreadyExists:title inManagedObjectContext:[self managedObjectContext]];
        if (!exists) {
            NSString* synopsis = [movie valueForKey:@"synopsis"];
            NSDictionary* posters = [movie valueForKey:@"posters"];
            NSString* thumbnailURL = [posters valueForKey:@"thumbnail"];
            [self createNewMovieWith:title andSynopsis:synopsis andURL:thumbnailURL];
        }
    }
    
}

- (void)createNewMovieWith:(NSString*)title andSynopsis:(NSString*)synopsis andURL:(NSString*)url{
    NSManagedObjectContext* moc = [self managedObjectContext];
    Movie* newMovie = [NSEntityDescription insertNewObjectForEntityForName:@"Movie" inManagedObjectContext:moc];
    newMovie.title = title;
    newMovie.synopsis = synopsis;
    newMovie.thumbnailURL = url;
    
    NSError* error;
    [moc save:&error];
    if (error) {
        NSLog(@"error saving new Movie: %@", error.description);
    }
    
}

- (BOOL)alreadyExists:(NSString*)movieNamed inManagedObjectContext:(NSManagedObjectContext*)context {
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"title == %@", movieNamed];
    NSEntityDescription* description = [NSEntityDescription entityForName:@"Movie" inManagedObjectContext:context];
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:description];
    [fetchRequest setPredicate:predicate];
    NSError* error;
    NSArray* fetchedResult = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
    
    if (fetchedResult.count == 0) {
        return NO;
    }
    else {
        return YES;
    }

}


- (NSManagedObjectContext*)managedObjectContext {
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return [appDelegate managedObjectContext];
}

@end
