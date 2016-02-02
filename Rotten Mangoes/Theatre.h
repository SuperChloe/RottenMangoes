//
//  Theatre.h
//  Rotten Mangoes
//
//  Created by Chloe on 2016-02-02.
//  Copyright © 2016 Chloe Horgan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Theatre : NSObject <MKAnnotation>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *address;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;

@end
