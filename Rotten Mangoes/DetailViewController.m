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
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *showTheatresButton;

@property (weak, nonatomic) IBOutlet UILabel *critic1;
@property (weak, nonatomic) IBOutlet UILabel *publication1;
@property (weak, nonatomic) IBOutlet UILabel *quote1;
@property (weak, nonatomic) IBOutlet UITextView *url1;
@property (weak, nonatomic) IBOutlet UILabel *critic2;
@property (weak, nonatomic) IBOutlet UILabel *publication2;
@property (weak, nonatomic) IBOutlet UILabel *quote2;
@property (weak, nonatomic) IBOutlet UITextView *url2;
@property (weak, nonatomic) IBOutlet UILabel *critic3;
@property (weak, nonatomic) IBOutlet UILabel *publication3;
@property (weak, nonatomic) IBOutlet UILabel *quote3;
@property (weak, nonatomic) IBOutlet UITextView *url3;

@end

@implementation DetailViewController

static NSString *ROTTEN_TOMATO_APIKEY = @"j9fhnct2tp8wu2q9h75kanh9";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.reviewArray = [[NSMutableArray alloc] init];
    
    self.titleLabel.text = self.movie.movieName;
    self.descriptionLabel.text = self.movie.movieDescription;
    self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.movie.movieImage]]];
    self.showTheatresButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    [self loadDetailData];    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper methods

- (void)loadDetailData {
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0/movies/%@/reviews.json?apikey=%@&page_limit=3", self.movie.movieId, ROTTEN_TOMATO_APIKEY];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            NSError *jsonParsingError;
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            if (!jsonParsingError) {
                NSLog(@"%@", jsonData);
                
                for (NSDictionary *reviewDictionary in jsonData[@"reviews"]) {
                    Review *review = [[Review alloc] init];
                    review.critic = reviewDictionary[@"critic"];
                    review.publication = reviewDictionary[@"publication"];
                    review.quote = reviewDictionary[@"quote"];
                    review.url = reviewDictionary[@"links"][@"review"];
                    
                    [self.reviewArray addObject:review];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    Review *review1 = self.reviewArray[0];
                    Review *review2 = self.reviewArray[1];
                    Review *review3 = self.reviewArray[2];
                    
                    self.critic1.text = review1.critic;
                    self.publication1.text = review1.publication;
                    self.quote1.text = review1.quote;
                    self.url1.text = review1.url;
                    
                    self.critic2.text = review2.critic;
                    self.publication2.text = review2.publication;
                    self.quote2.text = review2.quote;
                    self.url2.text = review2.url;
                    
                    self.critic3.text = review3.critic;
                    self.publication3.text = review3.publication;
                    self.quote3.text = review3.quote;
                    self.url3.text = review3.url;
                });
            }
        }
    }];
    [dataTask resume];
}

@end
