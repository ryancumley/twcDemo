//
//  TableViewController.m
//  BoxOfficePreview
//
//  Created by Ryan Cumley on 11/12/13.
//  Copyright (c) 2013 Ryan Cumley. All rights reserved.
//

#import "TableViewController.h"
#import "AppDelegate.h"
#import "CustomCell.h"

#define k_cellID @"cellID"

@interface TableViewController ()

@end

@implementation TableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        //we loaded the data from the http request into a property of AppDelegate, so we lazily copy it here now for consumption by the TableView. A more proper approach would be to push the fetched data into CoreData, ignoring duplicate entries, then retrieve with calls to the persistent store here. That would also have taken longer than 1.5 hrs to write correctly...
        _fetchedMovies = [[NSMutableArray alloc] init];// initialize an empty array until the data loads
        titles = [[NSMutableArray alloc] init]; //lazy getters would be a better choice. TODO verify if that is true...
        synopsis = [[NSMutableArray alloc] init];
        thumbnails = [[NSMutableArray alloc] init]; //just the URL's
        thumbnailImages = [[NSMutableArray alloc] init]; //this holds the actual images
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[CustomCell class] forCellReuseIdentifier:k_cellID];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"count: %u", _fetchedMovies.count);
    return [_fetchedMovies count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:k_cellID forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[titles objectAtIndex:indexPath.row]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[synopsis objectAtIndex:indexPath.row]];
    cell.imageView.image = [thumbnailImages objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - 
#pragma mark methods promised in the fetchedData delegate protocol

- (void)fetchCompletedWithData:(NSMutableArray *)data {
    //Rather than pushing this data through a persistent store, de-duping, etc... we are manually shoving it into the tableview via this instance variable, everytime something new loads.
    _fetchedMovies = [data copy];
    
    NSUInteger numberOfReturnedMovies = [_fetchedMovies count];
    
    //parse the data to populate our instance variables for staging.
    //performing this step now will make the response snappier for the TableViewDataSource methods.
    [titles removeAllObjects];
    [synopsis removeAllObjects];
    [thumbnails removeAllObjects];
    
    for (int i = 0; i < numberOfReturnedMovies; i++) {
        NSDictionary* movie = [_fetchedMovies objectAtIndex:i];
        [titles addObject:[movie valueForKey:@"title"]];
        [synopsis addObject:[movie valueForKey:@"synopsis"]];
        NSDictionary* posters = [movie valueForKey:@"posters"];
        [thumbnails addObject:[posters valueForKey:@"thumbnail"]];
    }
    
    [self populateImagesFromURLs];
}

- (void)populateImagesFromURLs {
    [thumbnailImages removeAllObjects];
    
    for (NSString* path in thumbnails) {
        UIImage* newImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:path]]];
        [thumbnailImages addObject:newImage];
    }
    
    [self.tableView reloadData];
}

@end
