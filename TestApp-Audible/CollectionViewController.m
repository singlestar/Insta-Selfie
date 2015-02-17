//
//  CollectionViewController.m
//  TestApp-Audible
//
//  Created by Rajesh kumar Subbiah on 2/16/15.
//  Copyright (c) 2015 Rajesh kumar Subbiah. All rights reserved.
//

#import "CollectionViewController.h"
#import "AFNetworking.h"
#import "PhotoViewController.h"

@interface CollectionViewController ()

@property(strong, nonatomic) NSArray *imagesurl;
@property(strong, nonatomic) NSMutableArray *imagesData;
@property(nonatomic) int counter;

@end

@implementation CollectionViewController

-(NSMutableArray *)imagesData
{
    if(!_imagesData)
    {
        _imagesData = [[NSMutableArray alloc]init];
    }
    return _imagesData;
}

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
    
    NSString *path = @"https://api.instagram.com/v1/tags/selfie/media/recent?access_token=189975156.78ad387.d40bc1523cd44853ae50ec31a8a1fb94";
    
    //NSLog(@"path %@", path);
    self.counter = 1;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        self.imagesurl = [[[[responseObject valueForKey:@"data"]valueForKey:@"images"]valueForKey:@"low_resolution"]valueForKey:@"url"];
        [self.collectionView reloadData];
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Instagram Data"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        
    }];
    [operation start];
    for(int i=0;i<50;i++)
        [self.imagesData addObject:[NSNull null]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imagesurl.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    
    NSURL *imageUrl =[NSURL URLWithString:[self.imagesurl objectAtIndex:indexPath.row]];
    
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(q, ^{
        /* Fetch the image from the server... */
        NSData *data = [NSData dataWithContentsOfURL:imageUrl];
        UIImage *img = [[UIImage alloc] initWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            /* This is the main thread again, where we set the tableView's image to
             be what we just fetched. */

            imageView.image = img;
            [self.imagesData replaceObjectAtIndex:indexPath.row withObject:img];
        });
    });
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if(self.counter == 1)
    {
        self.counter ++;
        return CGSizeMake(150, 100);
    }
    else if(self.counter == 2)
    {
        self.counter ++;
        return CGSizeMake(75, 100);
    }
    else if(self.counter == 3)
    {
        self.counter=1;
        return CGSizeMake(75, 100);
    }
    else
    return CGSizeMake(100, 100);
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 0, 5, 0);
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"Detail Segue"])
    {
        if([segue.destinationViewController isKindOfClass:[PhotoViewController class]])
        {
            NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
            PhotoViewController *targetViewController = segue.destinationViewController;
            NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
            targetViewController.image = [self.imagesData objectAtIndex:indexPath.row];
        }
    }

}


@end
