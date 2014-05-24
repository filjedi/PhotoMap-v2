//
//  RGMPhotosTableViewController.m
//  PhotoMap
//
//  Created by Ramon Pastor on 5/14/14.
//  Copyright (c) 2014 Rogomi Inc. All rights reserved.
//

#import "RGMPhotosTableViewController.h"
#import "RGMMapViewAnnotation.h"

@interface RGMPhotosTableViewController ()

@end

@implementation RGMPhotosTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [_annotations count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AnnotationCell" forIndexPath:indexPath];
    
    // Configure the cell...
    RGMMapViewAnnotation *annotation = _annotations[indexPath.row];
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        MKUserLocation *userLocation = (MKUserLocation *)annotation;
        cell.imageView.image = nil;
        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"lat %f ; lon %f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude];
    }
    else {
        UIImage *resizedImage = [[UIImage alloc] initWithCGImage:annotation.annotationImage.CGImage scale:64.0 orientation:UIImageOrientationUp];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.imageView.image = resizedImage;
        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"lat %f ; lon %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
    }
    cell.textLabel.text = annotation.title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma Navigation Bar Delegate
- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
