//
//  RGMMapViewController.h
//  PhotoMap
//
//  Created by Ramon Pastor on 5/14/14.
//  Copyright (c) 2014 Rogomi Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface RGMMapViewController : UIViewController <MKMapViewDelegate, UINavigationBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITabBarControllerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *photoMapView;
@property (strong, nonatomic) MKUserLocation *previousLocation;

- (IBAction)refreshUserLocation:(id)sender;
- (IBAction)takePicture:(id)sender;

@end
