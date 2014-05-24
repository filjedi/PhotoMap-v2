//
//  RGMMapViewController.m
//  PhotoMap
//
//  Created by Ramon Pastor on 5/14/14.
//  Copyright (c) 2014 Rogomi Inc. All rights reserved.
//

#import "RGMMapViewController.h"
#import "RGMMapViewAnnotation.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface RGMMapViewController ()

@end

@implementation RGMMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tabBarController.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark View Controller Methods
- (IBAction)refreshUserLocation:(id)sender {
    [_photoMapView setRegion:MKCoordinateRegionMake(_photoMapView.userLocation.coordinate, MKCoordinateSpanMake(0.05, 0.05)) animated:YES];
}

- (IBAction)takePicture:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Take Photo from"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Camera", @"Photos", nil];
    [sheet showFromTabBar:self.tabBarController.tabBar];
}

#pragma mark Map View Delegate Methods
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (![_previousLocation isEqual:userLocation]) {
        _previousLocation = userLocation;
        [self refreshUserLocation:mapView];
    }
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    NSString *messsage = [[NSString alloc] initWithFormat:@"Error %li : %@", (long)[error code], [error localizedDescription]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Locating User"
                                                    message:messsage
                                                   delegate:nil
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];
    
    [alert show];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation {
    if([annotation isKindOfClass: [MKUserLocation class]]) {
        return nil;
    }
    
    static NSString *identifier = @"PhotoAnnotationView";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    RGMMapViewAnnotation *mva = (RGMMapViewAnnotation *)annotation;
    if (annotationView == nil) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.canShowCallout = YES;
    }
    UIImage *resizedImage = [[UIImage alloc] initWithCGImage:mva.annotationImage.CGImage scale:64.0 orientation:UIImageOrientationUp];
    annotationView.image = resizedImage;
//    NSLog(@"annotationView.image.size = %@", NSStringFromCGSize(annotationView.image.size));
    
    return annotationView;
}

#pragma Navigation Bar Delegate
- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#pragma mark Image Picker Controller Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 NSLog(@"Import Photo done");
                                 RGMMapViewAnnotation *annotation = [[RGMMapViewAnnotation alloc] init];
                                 annotation.annotationImage = image;
                                 
                                 NSDateFormatter *df = [[NSDateFormatter alloc] init];
                                 df.locale = [NSLocale currentLocale];
                                 df.dateStyle = NSDateFormatterShortStyle;
                                 df.timeStyle = NSDateFormatterShortStyle;

                                 if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
                                     annotation.coordinate = _photoMapView.userLocation.coordinate;
                                     annotation.title = [df stringFromDate:[NSDate date]];
                                 }
                                 else if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
                                     NSURL *assetURL = info[UIImagePickerControllerReferenceURL];
                                     ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                                     [library assetForURL:assetURL
                                              resultBlock:^(ALAsset *asset) {
                                                  CLLocation *location = [asset valueForProperty:@"ALAssetPropertyLocation"];
                                                  annotation.coordinate = location.coordinate;
                                                  NSLog(@"image lat %f lon %f", location.coordinate.latitude, location.coordinate.longitude);
                                                  annotation.title = [df stringFromDate:[asset valueForProperty:@"ALAssetPropertyDate"]];
                                              }
                                             failureBlock:^(NSError *error) {
                                                 NSString *message = [[NSString alloc] initWithFormat:@"Error %li : %@", (long)[error code], [error localizedDescription]];
                                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Photo Import Error" message:message delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                                                 [alert show];
                                             }];
                                 }
                                 [_photoMapView addAnnotation:annotation];
                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                     [_photoMapView setCenterCoordinate:annotation.coordinate animated:YES];
                                 });
                             }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 NSLog(@"Import Photo cancelled");
                             }];
}

#pragma mark Tab Bar Controller Delegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    NSLog(@"%s", __FUNCTION__);
    if (![viewController isEqual:self]) {
        [viewController setValue:_photoMapView.annotations forKeyPath:@"annotations"];
    }
}

#pragma mark Action Sheet Delegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        if (buttonIndex == 0) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Camera Not Available"
                                                                message:@"This device does not have a camera, or the camera is currently unavailable."
                                                               delegate:nil
                                                      cancelButtonTitle:@"Okay"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
        else if (buttonIndex == 1) {
            ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        ipc.delegate = self;
        [self presentViewController:ipc
                           animated:YES
                         completion:^{
                             NSLog(@"Import Photo started");
                         }];
    }}
@end
