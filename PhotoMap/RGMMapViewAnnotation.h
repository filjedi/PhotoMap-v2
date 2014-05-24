//
//  RGMMapViewAnnotation.h
//  PhotoMap
//
//  Created by Ramon Pastor on 5/14/14.
//  Copyright (c) 2014 Rogomi Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface RGMMapViewAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) UIImage *annotationImage;
@property (nonatomic, readwrite, copy) NSString *title;

@end
