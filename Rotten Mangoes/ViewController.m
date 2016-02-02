//
//  ViewController.m
//  Rotten Mangoes
//
//  Created by Chloe on 2016-02-01.
//  Copyright © 2016 Chloe Horgan. All rights reserved.
//

#import "ViewController.h"
#import "Movie.h"
#import "MovieCell.h"
#import "DetailViewController.h"

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) NSMutableArray *objects;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (assign, nonatomic) int pageNum;
@property (assign, nonatomic) int maxNum;

@end

@implementation ViewController

static NSString *ROTTEN_TOMATO_APIKEY = @"j9fhnct2tp8wu2q9h75kanh9";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.objects = [[NSMutableArray alloc] init];
    self.pageNum = 1;
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        Movie *movie = self.objects[indexPath.row];
        DetailViewController *controller = (DetailViewController *)segue.destinationViewController;
        controller.movie = movie;
    }
}

#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MovieCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    Movie *movie = self.objects[indexPath.row];
    cell.titleLabel.text = movie.movieName;
    cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:movie.movieImage]]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.objects.count - 1) {
        if (self.objects.count < self.maxNum) {
            self.pageNum++;
            [self loadData];
        }
    }
}

#pragma mark - Helper methods

- (void)loadData {
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?apikey=%@&page_limit=50&page=%d", ROTTEN_TOMATO_APIKEY, self.pageNum];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            NSError *jsonParsingError;
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            if (!jsonParsingError) {
                
                self.maxNum = [jsonData[@"total"] intValue];
                
                for (NSDictionary *movieDictionary in jsonData[@"movies"]) {
                    Movie *movie = [[Movie alloc] init];
                    movie.movieName = movieDictionary[@"title"];
                    movie.movieDescription = movieDictionary[@"synopsis"];
                    movie.movieImage = movieDictionary[@"posters"][@"original"];
                    movie.movieId = movieDictionary[@"id"];
                    
                    [self.objects addObject:movie];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                });
            }
        }
    }];
    [dataTask resume];
    
}

@end
