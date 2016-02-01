//
//  Movie.h
//  Rotten Mangoes
//
//  Created by Chloe on 2016-02-01.
//  Copyright © 2016 Chloe Horgan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Movie : NSObject

@property (strong, nonatomic) NSString *movieName;
@property (strong, nonatomic) NSString *movieDescription;
@property (strong, nonatomic) NSString *movieImage;

@end
