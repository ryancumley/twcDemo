//
//  ViewController.m
//  BoxOfficePreview
//
//  Created by Ryan Cumley on 11/12/13.
//  Copyright (c) 2013 Ryan Cumley. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tvc= [[TableViewController alloc] init];
    _tvc.view.frame = self.view.frame;
    _tvc.view.backgroundColor = [UIColor colorWithRed:49.0f/255.0f green:57.0f/255.0f blue:73.0f/255.0f alpha:1.0];
    [self.view addSubview:_tvc.view];
    
    _dataModelController = [[DataModelController alloc] init];
    [_dataModelController setCompletionDelegate:_tvc];
    [_dataModelController reloadRottenTomatoes];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
