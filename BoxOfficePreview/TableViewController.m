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
#import "Movie.h"

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStateFromPersistentStore) name:@"com.ryan.cumley.updatedData" object:nil];
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
    return [titles count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;//added to remove phantom trailing cell break lines below stock UITableView
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
#pragma mark Update state and refresh interface

//We registered to be notified when the data was reloaded from the web, and our notification fires updateStateFromPersistentStore

- (void)updateStateFromPersistentStore {
    // Fetch all the "Movie" entities from the persistent store
    NSManagedObjectContext* moc = [self managedObjectContext];
    NSEntityDescription* description = [NSEntityDescription entityForName:@"Movie" inManagedObjectContext:moc];
    NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity:description];
    [request setSortDescriptors:[NSArray arrayWithObjects:descriptor, nil]];
    NSError* error;
    NSMutableArray* movies = [NSMutableArray arrayWithArray:[moc executeFetchRequest:request error:&error]];
    if (error) {
        NSLog(@"error fetching Movies for TableView: %@",error.localizedDescription);
    }
    
    //Now let's populate our instance variables with this newly fetched and sorted data.
    //Since we're not particularly concerned about performance for data sets of this size, we may harshly overwrite everything
    [titles removeAllObjects];
    [synopsis removeAllObjects];
    [thumbnails removeAllObjects];
    
    for (int i = 0; i < movies.count; i++) {
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

- (NSManagedObjectContext*)managedObjectContext {
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return [appDelegate managedObjectContext];
}

@end
