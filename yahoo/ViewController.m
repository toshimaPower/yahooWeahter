//
//  ViewController.m
//  yahoo
//
//  Created by SGWORLD on 2012/12/20.
//  Copyright (c) 2012年 SGWORLD. All rights reserved.
//

#import "ViewController.h"
#import "TBXML+HTTP.h"
#import "Reachability.h"
#import <CoreLocation/CoreLocation.h>
#import "mySQLite.h"

@interface ViewController ()<CLLocationManagerDelegate,UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *startLocation;
@property (nonatomic, strong) NSMutableArray *today;
@property (nonatomic, strong) NSMutableArray *tomorrow;
@property (nonatomic, strong) NSString *cityS;
@property (nonatomic, strong) NSArray *array;
@property (nonatomic) float latitude;
@property (nonatomic) float longtitude;

@end

@implementation ViewController

void (^tbxmlSuccessBlock2)(TBXML *) = ^(TBXML * tbxml)
{
    TBXMLElement *elemRoot = nil;
    elemRoot = tbxml.rootXMLElement;
    if(elemRoot)
    {
        
        TBXMLElement *resultElement = [TBXML childElementNamed:@"Result" parentElement:elemRoot];
        TBXMLElement *woeidElement = [TBXML childElementNamed:@"woeid" parentElement:resultElement];
        NSString *woeid = [TBXML textForElement:woeidElement];
        NSLog(@"woeid %@",woeid);
        NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:woeid,@"woeid", nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"woeidNoti" object:nil userInfo:dic];
        woeidElement = woeidElement ->nextSibling;
    }
    
};




void (^tbxmlSuccessBlock)(TBXML *) = ^(TBXML * tbxml)
{
    
    // 최상위 엘리먼트 (current), weather 엘리먼트, local 엘리먼트를 가리킬 포인터 생성
    TBXMLElement *elemRoot = nil, *elemWeather = nil;
    
    //날짜 정보를 담을 스트링 포인터 생성
   
    //최상위 엘리먼트의 주소를 가져옴
    elemRoot = tbxml.rootXMLElement;
  
    if(elemRoot)
            
    { //최상위 엘리먼트가 존재 한다면 (즉, xml을 제대로 읽었다면)
         //           elemWeather = [TBXML childElementNamed:@"channel" parentElement:elemRoot];
        TBXMLElement *channelElement = [TBXML childElementNamed:@"channel" parentElement:elemRoot];
        TBXMLElement *itemElement = [TBXML childElementNamed:@"item" parentElement:channelElement];
        TBXMLElement *locationElement = [TBXML childElementNamed:@"yweather:location" parentElement:channelElement];
        if(locationElement)
        {
            NSString *city = [TBXML valueOfAttributeNamed:@"city" forElement:locationElement];
            NSLog(@"city %@",city);
            NSDictionary *cityDict = [[NSDictionary alloc]initWithObjectsAndKeys:city,@"city", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"cityInfo" object:nil userInfo:cityDict];
        }
        elemWeather = [TBXML childElementNamed:@"yweather:forecast" parentElement:itemElement];
        //날씨 엘리먼트가 존재한다면
        if(elemWeather)
        {
      
            
            NSString *day = [TBXML valueOfAttributeNamed:@"day" forElement:elemWeather];
      
            NSString *date = [TBXML valueOfAttributeNamed:@"date" forElement:elemWeather];
      
            NSString *row = [TBXML valueOfAttributeNamed:@"low" forElement:elemWeather];
      
            NSString *high = [TBXML valueOfAttributeNamed:@"high" forElement:elemWeather];
      
            NSString *text = [TBXML valueOfAttributeNamed:@"text" forElement:elemWeather];
      
            NSString *code = [TBXML valueOfAttributeNamed:@"code" forElement:elemWeather];
           
           
            NSDictionary *today = [[NSDictionary alloc]initWithObjectsAndKeys:day,@"day",date,@"date",row,@"row",high,@"high",text,@"text",code,@"code", nil];
 
            [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveWeatherInfo" object:nil userInfo:today];
                elemWeather = &[TBXML childElementNamed:@"yweather:forecast" parentElement:itemElement][1];
            
                NSString *day2 = [TBXML valueOfAttributeNamed:@"day" forElement:elemWeather];
            
                NSString *date2 = [TBXML valueOfAttributeNamed:@"date" forElement:elemWeather];
            
                NSString *row2 = [TBXML valueOfAttributeNamed:@"low" forElement:elemWeather];
            
                NSString *high2 = [TBXML valueOfAttributeNamed:@"high" forElement:elemWeather];
            
                NSString *text2 = [TBXML valueOfAttributeNamed:@"text" forElement:elemWeather];
            
                NSString *code2 = [TBXML valueOfAttributeNamed:@"code" forElement:elemWeather];
     
            NSDictionary *dateDic2 = [[NSDictionary alloc]initWithObjectsAndKeys:day2,@"day",date2,@"date",row2,@"row",high2,@"high",text2,@"text",code2,@"code", nil];
                NSLog(@"dateDic2 %@",dateDic2);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"recieveNewItem" object:nil userInfo:dateDic2];
            elemWeather = elemWeather->nextSibling;
        }
    }
   
};

- (NSString *)day:(NSString*)aDay
{
    if([aDay isEqualToString:@"Sun"])
    {
        return [NSString stringWithFormat:@"日曜日"];
    }
    else if([aDay isEqualToString:@"Mon"])
    {
        return [NSString stringWithFormat:@"月曜日"];
    }
    else if([aDay isEqualToString:@"Tue"])
    {
        return [NSString stringWithFormat:@"火曜日"];
    }
    else if([aDay isEqualToString:@"Wed"])
    {
        return [NSString stringWithFormat:@"水曜日"];
    }
    else if([aDay isEqualToString:@"Thu"])
    {
        return [NSString stringWithFormat:@"木曜日"];
    }
    else if([aDay isEqualToString:@"Fri"])
    {
        return [NSString stringWithFormat:@"金曜日"];
    }
    else if([aDay isEqualToString:@"Sat"])
    {
        return [NSString stringWithFormat:@"土曜日"];
    }
    return nil;
    
    
}

void (^tbxmlFailureBlock)(TBXML *,NSError *) = ^(TBXML *tbxml,NSError *error)
{
    NSLog(@"Error : %@",error);
};

- (void)xmlParse:(NSInteger)num
{
    NSURL *weatherURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://weather.yahooapis.com/forecastrss?w=%d&u=c",num]];
    [TBXML newTBXMLWithURL:weatherURL success:tbxmlSuccessBlock failure:tbxmlFailureBlock];
}


- (void)parseXML
{
 
//   NSString* weatherURLString = [NSString stringWithFormat:@"http://weather.yahooapis.com/forecastrss?p=9408"];
//    NSURL *weatherUrl = [NSURL URLWithString:weatherURLString];
//    NSString *tenoForWeather = [NSString stringWithContentsOfURL:weatherUrl encoding:NSShiftJISStringEncoding error:nil];
//  / TBXML *weatherXML = [TBXML newTBXMLWithXMLString:tenoForWeather error:nil];
     NSURL *weatherURL = [NSURL URLWithString:@"http://weather.yahooapis.com/forecastrss?w=1118550&u=f"];
   [TBXML newTBXMLWithURL:weatherURL success:tbxmlSuccessBlock failure:tbxmlFailureBlock];
   
  
}



- (void)woeidNoti:(NSNotification *)noti
{
    NSDictionary *woeidInfo = [[NSDictionary alloc]initWithDictionary:[noti userInfo]];
    NSInteger woeid = [[woeidInfo objectForKey:@"woeid"]integerValue];
   
    
    
    //[NSThread detachNewThreadSelector:@selector(parseXML) toTarget:self withObject:nil];
    // [NSThread detachNewThreadSelector:@selector(xmlParse:) toTarget:self   withObject:nil];
    [self xmlParse:woeid];
}



- (void)recieveWeatherInfo:(NSNotification *)noti
{
    NSLog(@"Hello Recieve");
    NSDictionary *dateInfo = [[NSDictionary alloc]initWithDictionary:[noti userInfo]];
    
    
    NSString *day = [self day:[dateInfo objectForKey:@"day"]];
    NSString *date = [dateInfo objectForKey:@"date"];
    NSString *row = [dateInfo objectForKey:@"row"];
    NSString *high = [dateInfo objectForKey:@"high"];
    NSString *text = [dateInfo objectForKey:@"text"];
 //   NSString *code = [dateInfo objectForKey:@"code"];
    
    self.today = [NSMutableArray arrayWithObjects:day,date,row,high,text, nil];
  //  [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
  
}

- (void)cityInfo:(NSNotification *)noti
{
    NSDictionary *dateInfo = [[NSDictionary alloc]initWithDictionary:[noti userInfo]];
    self.cityS = [dateInfo objectForKey:@"city"];
    
}
- (void)recieveNewItem:(NSNotification *)noti
{
    NSDictionary *dateInfo = [[NSDictionary alloc]initWithDictionary:[noti userInfo]];
    
    
    NSString *day = [self day:[dateInfo objectForKey:@"day"]];
    NSString *date = [dateInfo objectForKey:@"date"];
    NSString *row = [dateInfo objectForKey:@"row"];
    NSString *high = [dateInfo objectForKey:@"high"];
    NSString *text = [dateInfo objectForKey:@"text"];
 //   NSString *code = [dateInfo objectForKey:@"code"];
    self.tomorrow = [NSMutableArray arrayWithObjects:day,date,row,high,text, nil];

    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    NSLog(@"end");
    
}


#pragma mark -Location
- (void)location
{
    NSLog(@"1");
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest; //10M
    
    [self.locationManager startUpdatingLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location Update Failed");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"location");
    
    self.latitude = newLocation.coordinate.latitude ; //위도
    self.longtitude = newLocation.coordinate.longitude; //경도
    
    [self.locationManager stopUpdatingLocation];
    [self makeWoeid];
    //   self.locationManager = nil;
}

- (void)makeWoeid
{
    NSString *apiKey = @"HUMMb5jV34F2drtAdYYOImz_pgrklK0Y8psSMJYXGPNjQgK1rKQMtspxf1Kg.4yqsCkaAFYZ7LyFiugtzT_CzsfJZ8yMLIM-";
    NSString *urlString = [NSString stringWithFormat:@"http://where.yahooapis.com/geocode?q=%f,%f&gflags=R&appid=%@",self.latitude,self.longtitude,apiKey];
    NSURL *xmlUrl = [NSURL URLWithString:urlString];
    NSLog(@"urlString %@",urlString);
    //    NSURL *url = [NSURL URLWithString:urlString];
    //    TBXML *tbxml = [TBXML n] =
    //    [self.tableView reloadData];
    [TBXML newTBXMLWithURL:xmlUrl success:tbxmlSuccessBlock2 failure:tbxmlFailureBlock];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if(![self isNetworkEnable])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Not is Network Enable" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
      [self location];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityInfo:) name:@"cityInfo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(woeidNoti:) name:@"woeidNoti" object:nil];

     [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(recieveWeatherInfo:) name:@"recieveWeatherInfo" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(recieveNewItem:) name:@"recieveNewItem" object:nil];
 //   [NSThread detachNewThreadSelector:@selector(parseXML) toTarget:self withObject:nil];
    self.array = [NSArray arrayWithObjects:@"曜日　　　　　：",@"日日　　　　　：",@"最低気温　　   ：",@"最高気温　　   ：",@"天気　　　　　：" ,nil];
   
}
- (BOOL)isNetworkEnable
{
    Reachability *isConnect = [Reachability reachabilityForInternetConnection];
    
    switch ([isConnect currentReachabilityStatus]) {
        case ReachableViaWWAN:
        case ReachableViaWiFi:
            break;
        case NotReachable:
            return NO;
            break;
        default:
            break;
    }
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == alertView.cancelButtonIndex)
    {
        NSLog(@"Hello");
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 1:
            return [self.today count];
            break;
            
        case 2:
            return [self.tomorrow count];
            break;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [NSString stringWithString:[NSString stringWithFormat:@"場所　%@",self.cityS]];
            break;
        case 1:
            return @"今日の天気";
            break;
        case 2:
            return @"明日の天気";
            break;
        
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
  //  NSString *sg = [self.today objectAtIndex:indexPath.row];
  //  NSString *day = [sg objectForKey:@"day"];
  //  NSLog(@"sg %@",day);
 //   cell.textLabel.text = sg;
   
    NSString *sg;
    if(indexPath.section == 1)
    {
        
        sg = [self.today objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 2)
    {
        sg = [self.tomorrow objectAtIndex:indexPath.row];
    }
    cell.detailTextLabel.text = sg;
    cell.textLabel.text = [self.array objectAtIndex:indexPath.row];
    
    
    return cell;
}



- (void) resea
{
    self.locationManager = nil;
    self.today = nil;
    self.tomorrow = nil;
    self.cityS = nil;
 //   self.array = nil;
}
/*
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    
 //   [self resea];
    NSLog(@"search %@",searchBar);
    mySQLite *sq = [[mySQLite alloc]init];
 //   [sq findWoeid:searchBar.text];
 //   [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    [self searchParseXML:[sq findWoeid:searchBar.text]];
    NSLog(@"123");
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    NSLog(@"asdfa");
    
}
*/

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"search %@",searchBar);
    mySQLite *sq = [[mySQLite alloc]init];
    //   [sq findWoeid:searchBar.text];
    //   [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    [self searchParseXML:[sq findWoeid:searchBar.text]];
    NSLog(@"123");
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    NSLog(@"asdfa");

}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"search %@",searchBar);
    mySQLite *sq = [[mySQLite alloc]init];
    //   [sq findWoeid:searchBar.text];
    //   [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    [self searchParseXML:[sq findWoeid:searchBar.text]];
    NSLog(@"123");
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    NSLog(@"asdfa");

}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"search %@",searchBar);
    mySQLite *sq = [[mySQLite alloc]init];
    //   [sq findWoeid:searchBar.text];
    //   [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    [self searchParseXML:[sq findWoeid:searchBar.text]];
    NSLog(@"123");
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    NSLog(@"asdfa");

}

- (void)searchParseXML:(NSInteger)num
{
    
    //   NSString* weatherURLString = [NSString stringWithFormat:@"http://weather.yahooapis.com/forecastrss?p=9408"];
    //    NSURL *weatherUrl = [NSURL URLWithString:weatherURLString];
    //    NSString *tenoForWeather = [NSString stringWithContentsOfURL:weatherUrl encoding:NSShiftJISStringEncoding error:nil];
    //  / TBXML *weatherXML = [TBXML newTBXMLWithXMLString:tenoForWeather error:nil];
//    NSURL *weatherURL = [NSURL URLWithString:@"http://weather.yahooapis.com/forecastrss?w=%d&u=c",num]; //차이 
//    [TBXML newTBXMLWithURL:weatherURL success:tbxmlSuccessBlock failure:tbxmlFailureBlock];
    
    NSURL *weatherURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://weather.yahooapis.com/forecastrss?w=%d&u=c",num]];
    
    NSLog(@"weatherURL %@",weatherURL);
    [TBXML newTBXMLWithURL:weatherURL success:tbxmlSuccessBlock failure:tbxmlFailureBlock];
    
}




- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setDisplayedCellsHidden:(BOOL)hidden
{
    for (UIView* view in self.tableView.subviews) {
        if ([view isKindOfClass:[UITableViewCell class]]) {
            view.hidden = hidden;
        }
    }
}

// 検索開始
- (void)searchDisplayController:(UISearchDisplayController *)controller
 willShowSearchResultsTableView:(UITableView *)tableView
{
    NSLog(@"asdfasdfasdfasdf");
    [self setDisplayedCellsHidden:YES];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self resea];
    self.array = nil;
    [super viewDidUnload];
}
@end
