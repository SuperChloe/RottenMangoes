//
//  DetailViewController.m
//  Rotten Mangoes
//
//  Created by Chloe on 2016-02-01.
//  Copyright © 2016 Chloe Horgan. All rights reserved.
//

#import "DetailViewController.h"
#import "Review.h"

@interface DetailViewController ()

@property (strong, nonatomic) NSMutableArray *reviewArray;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = self.movie.movieName;
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSString *urlString = self.movie.reviewURL;
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            NSError *jsonParsingError;
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            if (!jsonParsingError) {
                NSLog(@"%@", jsonData);
                
                NSMutableArray *reviewList = [NSMutableArray array];
                for (NSDictionary *reviewDictionary in jsonData[@"reviews"]) {
                    Review *review = [[Review alloc] init];
                    review.critic = reviewDictionary[@"critic"];
                    review.publication = reviewDictionary[@"publication"];
                    review.quote = reviewDictionary[@"quote"];
                    
                    [reviewList addObject:review];
                }
                self.reviewArray = reviewList;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Display reviews
                });
            }
        }
    }];
    [dataTask resume];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
