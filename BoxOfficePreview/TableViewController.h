//
//  TableViewController.h
//  BoxOfficePreview
//
//  Created by Ryan Cumley on 11/12/13.
//  Copyright (c) 2013 Ryan Cumley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCell.h"
#import "DataModelController.h"
#import "AppDelegate.h"

@interface TableViewController : UITableViewController
{
    NSMutableArray* titles;
    NSMutableArray* synopsis;
    NSMutableArray* thumbnails;
    NSMutableArray* thumbnailImages;
}

@end
