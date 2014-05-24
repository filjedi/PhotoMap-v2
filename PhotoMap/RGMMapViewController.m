//
//  RGMMapViewController.m
//  PhotoMap
//
//  Created by Ramon Pastor on 5/23/14.
//  Copyright (c) 2014 Ramon Pastor. All rights reserved.
//

#import "RGMMapViewController.h"

#import "RGMMapViewAnnotation.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <Social/Social.h>

@interface RGMMapViewController ()

@end

@implementation RGMMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.tabBarController.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Map View Methods

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    NSString *messsage = [[NSString alloc] initWithFormat:@"Error %li : %@", (long)[error code], [error localizedDescription]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Locating User"
                                                    message:messsage
                                                   delegate:nil
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];
    
    [alert show];
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (![_previousLocation isEqual:userLocation]) {
        _previousLocation = userLocation;
        [self refreshUserLocation:mapView];
    }
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
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        annotationView.rightCalloutAccessoryView = rightButton;
    }
    UIImage *resizedImage = [[UIImage alloc] initWithCGImage:mva.annotationImage.CGImage scale:64.0 orientation:UIImageOrientationUp];
    annotationView.image = resizedImage;
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    NSLog(@"%s", __FUNCTION__);
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *fbSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        fbSheet.completionHandler = ^(SLComposeViewControllerResult result) {
            switch(result) {
                    //  This means the user cancelled without sending the Tweet
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"FB Sheet cancelled");
                    break;
                    //  This means the user hit 'Send'
                case SLComposeViewControllerResultDone:
                    NSLog(@"FB Sheet sent request");
                    break;
            }
        };
        
        RGMMapViewAnnotation *annotation = (RGMMapViewAnnotation *)view.annotation;
        [fbSheet addImage:annotation.annotationImage];
        [fbSheet setInitialText:annotation.title];
        [self presentViewController:fbSheet
                           animated:YES
                         completion:^{
                             NSLog(@"FBSheet presented");
                         }];
    }
    else {
        NSLog(@"Facebook not available");
    }
}

#pragma mark Navigation Bar Methods


- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

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

#pragma mark Image Picker Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:YES
                             completion:^{
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

#pragma mark Action Sheet Methods
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"buttonIndex = %li", (long)buttonIndex);
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
                return;
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
    }
}

#pragma mark Tab Bar Methods
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (![viewController isEqual:self]) {
        NSLog(@"_photoMapView.annotations = %@", _photoMapView.annotations);
        [viewController setValue:_photoMapView.annotations forKeyPath:@"annotations"];
    }
}
@end
