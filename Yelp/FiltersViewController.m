//
//  FiltersViewController.m
//  Yelp
//
//  Created by William Seo on 2/14/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "FiltersViewController.h"
#import "SwitchCell.h"
#import "SelectCell.h"

NSInteger const numberOfSections = 4;

@interface FiltersViewController () <UITableViewDataSource, UITableViewDelegate, SwitchDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, readonly) NSDictionary *filters;
@property (nonatomic, strong) NSMutableDictionary *expandedFilterSections;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSDictionary *sortTypes;
@property (nonatomic, strong) NSDictionary *radius;
@property (nonatomic, strong) NSMutableSet *selectedCategories;
@property (nonatomic, assign) NSInteger selectedSortType;
@property (nonatomic, assign) NSInteger selectedRadius;
@property (nonatomic, strong) NSString *isOfferingDeal;

- (void)initSortTypes;
- (void)initCategories;
- (void)initRadius;

@end

@implementation FiltersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        self.expandedFilterSections = [NSMutableDictionary dictionary];
        self.selectedCategories = [NSMutableSet set];
        self.selectedSortType = 0;
        self.selectedRadius = 0;
        self.isOfferingDeal = false;
        [self initCategories];
        [self initSortTypes];
        [self initRadius];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(onApplyButton)];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.title = @"Filters";
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SelectCell" bundle:nil] forCellReuseIdentifier:@"SelectCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return numberOfSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"Categories";
    switch (section) {
        // Categories
        case 0:
            title = @"Categories";
            break;
        // Sort
        case 1:
            title = @"Sort";
            break;
        // Radius
        case 2:
            title = @"Radius";
            break;
        // Deals
        case 3:
            title = @"Deals";
            break;
        default:
            title = @"Unknown section";
            break;
    }
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows;
    switch (section) {
        case 0: {
            if ([self.expandedFilterSections[@(section)] isEqual:@(true)]) {
                numberOfRows = self.categories.count + 1;
            } else {
                numberOfRows = 4;
            }
            break;
        }
        case 1: {
            if ([self.expandedFilterSections[@(section)] isEqual:@(true)]) {
                numberOfRows = self.sortTypes.count;
            } else {
                numberOfRows = 1;
            }
            break;
        }
        case 2:
            if ([self.expandedFilterSections[@(section)] isEqual:@(true)]) {
                numberOfRows = self.radius.count;
            } else {
                numberOfRows = 1;
            }
            break;
        case 3:
            numberOfRows = 1;
            break;
        default:
            numberOfRows = 1;
            break;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    SwitchCell *switchCell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
    SelectCell *selectCell = [tableView dequeueReusableCellWithIdentifier:@"SelectCell"];

    switch (indexPath.section) {
        case 0: {
            if ([self.expandedFilterSections[@(indexPath.section)] isEqual:@(true)]) {
                if (indexPath.row == self.categories.count) {
                    selectCell.titleLabel.text = @"Hide categories";
                    cell = selectCell;
                } else {
                    switchCell.titleLabel.text = self.categories[indexPath.row][@"name"];
                    switchCell.on = [self.selectedCategories containsObject:self.categories[indexPath.row]];
                    switchCell.delegate = self;
                    cell = switchCell;
                }
            } else {
                if (indexPath.row == 3) {
                    selectCell.titleLabel.text = @"See all";
                    cell = selectCell;
                } else {
                    switchCell.titleLabel.text = self.categories[indexPath.row][@"name"];
                    switchCell.on = [self.selectedCategories containsObject:self.categories[indexPath.row]];
                    switchCell.delegate = self;
                    cell = switchCell;
                }
            }
            break;
        }
        case 1: {
            NSDictionary *sortType;
            if ([self.expandedFilterSections[@(indexPath.section)] isEqual:@(true)]) {
                sortType = [self.sortTypes objectForKey:[NSString stringWithFormat:@"%@", @(indexPath.row)]];
                if (indexPath.row == self.selectedSortType) {
                    selectCell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            } else {
                sortType = [self.sortTypes objectForKey:[NSString stringWithFormat:@"%@", @(self.selectedSortType)]];
                selectCell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            selectCell.titleLabel.text = sortType[@"name"];
            cell = selectCell;
            break;
        }
        case 2: {
            NSDictionary *radius;
            if ([self.expandedFilterSections[@(indexPath.section)] isEqual:@(true)]) {
                radius = [self.radius objectForKey:[NSString stringWithFormat:@"%@", @(indexPath.row)]];
                if (indexPath.row == self.selectedRadius) {
                    selectCell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            } else {
                radius = [self.radius objectForKey:[NSString stringWithFormat:@"%@", @(self.selectedRadius)]];
                selectCell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            selectCell.titleLabel.text = radius[@"label"];
            cell = selectCell;
            break;
        }
        case 3: {
            switchCell.titleLabel.text = @"Offering a Deal";
            switchCell.on = [self.isOfferingDeal isEqualToString:@"1"];
            switchCell.delegate = self;
            cell = switchCell;
            break;
        }
        default:
            cell = selectCell;
            break;
    }
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 47;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0: {
            if ([self.expandedFilterSections[@(indexPath.section)] isEqual:@(true)]) {
                if (indexPath.row == self.categories.count) {
                    [self collapseFilterSection:indexPath.section];
                }
            } else {
                if (indexPath.row == 3) {
                    [self expandFilterSection:indexPath.section];
                }
            }
            break;
        }
        case 1: {
            SelectCell *currentCell = (SelectCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedSortType inSection:indexPath.section]];
            currentCell.accessoryType = UITableViewCellAccessoryNone;
            if ([self.expandedFilterSections[@(indexPath.section)] isEqual:@(true)]) {
                self.selectedSortType = indexPath.row;
                [self collapseFilterSection:indexPath.section];
            } else {
                [self expandFilterSection:indexPath.section];
            }
            break;
        }
        // Radius
        case 2: {
            SelectCell *currentCell = (SelectCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedRadius inSection:indexPath.section]];
            currentCell.accessoryType = UITableViewCellAccessoryNone;
            if ([self.expandedFilterSections[@(indexPath.section)] isEqual:@(true)]) {
                self.selectedRadius = indexPath.row;
                [self collapseFilterSection:indexPath.section];
            } else {
                [self expandFilterSection:indexPath.section];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - Switch cell delegate methods

- (void)switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    switch (indexPath.section) {
        case 0: {
            if (value) {
                [self.selectedCategories addObject:self.categories[indexPath.row]];
            } else {
                [self.selectedCategories removeObject:self.categories[indexPath.row]];
            }
            break;
        }
        case 3: {
            if (value) {
                self.isOfferingDeal = @"1";
            } else {
                self.isOfferingDeal = @"0";
            }
        }
        default:
            break;
    }
}

#pragma mark - Private methods

- (NSDictionary *)filters {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    
    if (self.selectedCategories.count > 0) {
        NSMutableArray *names = [NSMutableArray array];
        for (NSDictionary *category in self.selectedCategories) {
            [names addObject:category[@"code"]];
        }
        NSString *categoryFilter = [names componentsJoinedByString:@","];
        [filters setObject:categoryFilter forKey:@"category_filter"];
    }
    
    [filters setObject:[NSString stringWithFormat:@"%@", @(self.selectedSortType)] forKey:@"sort"];
    
    if (!(self.selectedRadius == 0)) {
        NSString *distance = self.radius[[NSString stringWithFormat:@"%@", @(self.selectedRadius)]][@"distance"];
        [filters setObject:distance forKey:@"radius_filter"];
    }
    
    if ([self.isOfferingDeal isEqualToString:@"1"]) {
        [filters setObject:self.isOfferingDeal forKey:@"deals_filter"];
    }

    return filters;
}

- (void)onCancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onApplyButton {
    [self.delegate filtersViewController:self didChangeFilters:self.filters];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initCategories {
    self.categories =
    @[@{@"name" : @"Afghan", @"code": @"afghani" },
      @{@"name" : @"African", @"code": @"african" },
      @{@"name" : @"American, New", @"code": @"newamerican" },
      @{@"name" : @"American, Traditional", @"code": @"tradamerican" },
      @{@"name" : @"Arabian", @"code": @"arabian" },
      @{@"name" : @"Argentine", @"code": @"argentine" },
      @{@"name" : @"Armenian", @"code": @"armenian" },
      @{@"name" : @"Asian Fusion", @"code": @"asianfusion" },
      @{@"name" : @"Asturian", @"code": @"asturian" },
      @{@"name" : @"Australian", @"code": @"australian" },
      @{@"name" : @"Austrian", @"code": @"austrian" },
      @{@"name" : @"Baguettes", @"code": @"baguettes" },
      @{@"name" : @"Bangladeshi", @"code": @"bangladeshi" },
      @{@"name" : @"Barbeque", @"code": @"bbq" },
      @{@"name" : @"Basque", @"code": @"basque" },
      @{@"name" : @"Bavarian", @"code": @"bavarian" },
      @{@"name" : @"Beer Garden", @"code": @"beergarden" },
      @{@"name" : @"Beer Hall", @"code": @"beerhall" },
      @{@"name" : @"Beisl", @"code": @"beisl" },
      @{@"name" : @"Belgian", @"code": @"belgian" },
      @{@"name" : @"Bistros", @"code": @"bistros" },
      @{@"name" : @"Black Sea", @"code": @"blacksea" },
      @{@"name" : @"Brasseries", @"code": @"brasseries" },
      @{@"name" : @"Brazilian", @"code": @"brazilian" },
      @{@"name" : @"Breakfast & Brunch", @"code": @"breakfast_brunch" },
      @{@"name" : @"British", @"code": @"british" },
      @{@"name" : @"Buffets", @"code": @"buffets" },
      @{@"name" : @"Bulgarian", @"code": @"bulgarian" },
      @{@"name" : @"Burgers", @"code": @"burgers" },
      @{@"name" : @"Burmese", @"code": @"burmese" },
      @{@"name" : @"Cafes", @"code": @"cafes" },
      @{@"name" : @"Cafeteria", @"code": @"cafeteria" },
      @{@"name" : @"Cajun/Creole", @"code": @"cajun" },
      @{@"name" : @"Cambodian", @"code": @"cambodian" },
      @{@"name" : @"Canadian", @"code": @"New)" },
      @{@"name" : @"Canteen", @"code": @"canteen" },
      @{@"name" : @"Caribbean", @"code": @"caribbean" },
      @{@"name" : @"Catalan", @"code": @"catalan" },
      @{@"name" : @"Chech", @"code": @"chech" },
      @{@"name" : @"Cheesesteaks", @"code": @"cheesesteaks" },
      @{@"name" : @"Chicken Shop", @"code": @"chickenshop" },
      @{@"name" : @"Chicken Wings", @"code": @"chicken_wings" },
      @{@"name" : @"Chilean", @"code": @"chilean" },
      @{@"name" : @"Chinese", @"code": @"chinese" },
      @{@"name" : @"Comfort Food", @"code": @"comfortfood" },
      @{@"name" : @"Corsican", @"code": @"corsican" },
      @{@"name" : @"Creperies", @"code": @"creperies" },
      @{@"name" : @"Cuban", @"code": @"cuban" },
      @{@"name" : @"Curry Sausage", @"code": @"currysausage" },
      @{@"name" : @"Cypriot", @"code": @"cypriot" },
      @{@"name" : @"Czech", @"code": @"czech" },
      @{@"name" : @"Czech/Slovakian", @"code": @"czechslovakian" },
      @{@"name" : @"Danish", @"code": @"danish" },
      @{@"name" : @"Delis", @"code": @"delis" },
      @{@"name" : @"Diners", @"code": @"diners" },
      @{@"name" : @"Dumplings", @"code": @"dumplings" },
      @{@"name" : @"Eastern European", @"code": @"eastern_european" },
      @{@"name" : @"Ethiopian", @"code": @"ethiopian" },
      @{@"name" : @"Fast Food", @"code": @"hotdogs" },
      @{@"name" : @"Filipino", @"code": @"filipino" },
      @{@"name" : @"Fish & Chips", @"code": @"fishnchips" },
      @{@"name" : @"Fondue", @"code": @"fondue" },
      @{@"name" : @"Food Court", @"code": @"food_court" },
      @{@"name" : @"Food Stands", @"code": @"foodstands" },
      @{@"name" : @"French", @"code": @"french" },
      @{@"name" : @"French Southwest", @"code": @"sud_ouest" },
      @{@"name" : @"Galician", @"code": @"galician" },
      @{@"name" : @"Gastropubs", @"code": @"gastropubs" },
      @{@"name" : @"Georgian", @"code": @"georgian" },
      @{@"name" : @"German", @"code": @"german" },
      @{@"name" : @"Giblets", @"code": @"giblets" },
      @{@"name" : @"Gluten-Free", @"code": @"gluten_free" },
      @{@"name" : @"Greek", @"code": @"greek" },
      @{@"name" : @"Halal", @"code": @"halal" },
      @{@"name" : @"Hawaiian", @"code": @"hawaiian" },
      @{@"name" : @"Heuriger", @"code": @"heuriger" },
      @{@"name" : @"Himalayan/Nepalese", @"code": @"himalayan" },
      @{@"name" : @"Hong Kong Style Cafe", @"code": @"hkcafe" },
      @{@"name" : @"Hot Dogs", @"code": @"hotdog" },
      @{@"name" : @"Hot Pot", @"code": @"hotpot" },
      @{@"name" : @"Hungarian", @"code": @"hungarian" },
      @{@"name" : @"Iberian", @"code": @"iberian" },
      @{@"name" : @"Indian", @"code": @"indpak" },
      @{@"name" : @"Indonesian", @"code": @"indonesian" },
      @{@"name" : @"International", @"code": @"international" },
      @{@"name" : @"Irish", @"code": @"irish" },
      @{@"name" : @"Island Pub", @"code": @"island_pub" },
      @{@"name" : @"Israeli", @"code": @"israeli" },
      @{@"name" : @"Italian", @"code": @"italian" },
      @{@"name" : @"Japanese", @"code": @"japanese" },
      @{@"name" : @"Jewish", @"code": @"jewish" },
      @{@"name" : @"Kebab", @"code": @"kebab" },
      @{@"name" : @"Korean", @"code": @"korean" },
      @{@"name" : @"Kosher", @"code": @"kosher" },
      @{@"name" : @"Kurdish", @"code": @"kurdish" },
      @{@"name" : @"Laos", @"code": @"laos" },
      @{@"name" : @"Laotian", @"code": @"laotian" },
      @{@"name" : @"Latin American", @"code": @"latin" },
      @{@"name" : @"Live/Raw Food", @"code": @"raw_food" },
      @{@"name" : @"Lyonnais", @"code": @"lyonnais" },
      @{@"name" : @"Malaysian", @"code": @"malaysian" },
      @{@"name" : @"Meatballs", @"code": @"meatballs" },
      @{@"name" : @"Mediterranean", @"code": @"mediterranean" },
      @{@"name" : @"Mexican", @"code": @"mexican" },
      @{@"name" : @"Middle Eastern", @"code": @"mideastern" },
      @{@"name" : @"Milk Bars", @"code": @"milkbars" },
      @{@"name" : @"Modern Australian", @"code": @"modern_australian" },
      @{@"name" : @"Modern European", @"code": @"modern_european" },
      @{@"name" : @"Mongolian", @"code": @"mongolian" },
      @{@"name" : @"Moroccan", @"code": @"moroccan" },
      @{@"name" : @"New Zealand", @"code": @"newzealand" },
      @{@"name" : @"Night Food", @"code": @"nightfood" },
      @{@"name" : @"Norcinerie", @"code": @"norcinerie" },
      @{@"name" : @"Open Sandwiches", @"code": @"opensandwiches" },
      @{@"name" : @"Oriental", @"code": @"oriental" },
      @{@"name" : @"Pakistani", @"code": @"pakistani" },
      @{@"name" : @"Parent Cafes", @"code": @"eltern_cafes" },
      @{@"name" : @"Parma", @"code": @"parma" },
      @{@"name" : @"Persian/Iranian", @"code": @"persian" },
      @{@"name" : @"Peruvian", @"code": @"peruvian" },
      @{@"name" : @"Pita", @"code": @"pita" },
      @{@"name" : @"Pizza", @"code": @"pizza" },
      @{@"name" : @"Polish", @"code": @"polish" },
      @{@"name" : @"Portuguese", @"code": @"portuguese" },
      @{@"name" : @"Potatoes", @"code": @"potatoes" },
      @{@"name" : @"Poutineries", @"code": @"poutineries" },
      @{@"name" : @"Pub Food", @"code": @"pubfood" },
      @{@"name" : @"Rice", @"code": @"riceshop" },
      @{@"name" : @"Romanian", @"code": @"romanian" },
      @{@"name" : @"Rotisserie Chicken", @"code": @"rotisserie_chicken" },
      @{@"name" : @"Rumanian", @"code": @"rumanian" },
      @{@"name" : @"Russian", @"code": @"russian" },
      @{@"name" : @"Salad", @"code": @"salad" },
      @{@"name" : @"Sandwiches", @"code": @"sandwiches" },
      @{@"name" : @"Scandinavian", @"code": @"scandinavian" },
      @{@"name" : @"Scottish", @"code": @"scottish" },
      @{@"name" : @"Seafood", @"code": @"seafood" },
      @{@"name" : @"Serbo Croatian", @"code": @"serbocroatian" },
      @{@"name" : @"Signature Cuisine", @"code": @"signature_cuisine" },
      @{@"name" : @"Singaporean", @"code": @"singaporean" },
      @{@"name" : @"Slovakian", @"code": @"slovakian" },
      @{@"name" : @"Soul Food", @"code": @"soulfood" },
      @{@"name" : @"Soup", @"code": @"soup" },
      @{@"name" : @"Southern", @"code": @"southern" },
      @{@"name" : @"Spanish", @"code": @"spanish" },
      @{@"name" : @"Steakhouses", @"code": @"steak" },
      @{@"name" : @"Sushi Bars", @"code": @"sushi" },
      @{@"name" : @"Swabian", @"code": @"swabian" },
      @{@"name" : @"Swedish", @"code": @"swedish" },
      @{@"name" : @"Swiss Food", @"code": @"swissfood" },
      @{@"name" : @"Tabernas", @"code": @"tabernas" },
      @{@"name" : @"Taiwanese", @"code": @"taiwanese" },
      @{@"name" : @"Tapas Bars", @"code": @"tapas" },
      @{@"name" : @"Tapas/Small Plates", @"code": @"tapasmallplates" },
      @{@"name" : @"Tex-Mex", @"code": @"tex-mex" },
      @{@"name" : @"Thai", @"code": @"thai" },
      @{@"name" : @"Traditional Norwegian", @"code": @"norwegian" },
      @{@"name" : @"Traditional Swedish", @"code": @"traditional_swedish" },
      @{@"name" : @"Trattorie", @"code": @"trattorie" },
      @{@"name" : @"Turkish", @"code": @"turkish" },
      @{@"name" : @"Ukrainian", @"code": @"ukrainian" },
      @{@"name" : @"Uzbek", @"code": @"uzbek" },
      @{@"name" : @"Vegan", @"code": @"vegan" },
      @{@"name" : @"Vegetarian", @"code": @"vegetarian" },
      @{@"name" : @"Venison", @"code": @"venison" },
      @{@"name" : @"Vietnamese", @"code": @"vietnamese" },
      @{@"name" : @"Wok", @"code": @"wok" },
      @{@"name" : @"Wraps", @"code": @"wraps" },
      @{@"name" : @"Yugoslav", @"code": @"yugoslav" }
      ];
}

- (void)initSortTypes {
    self.sortTypes =
    @{
      @"0" : @{ @"name" : @"Best Match"},
      @"1" : @{ @"name" : @"Distance"},
      @"2" : @{ @"name" : @"Highest Rated"}
    };
}

- (void)initRadius {
    self.radius =
    @{
      @"0" : @{ @"distance" : @"auto", @"label" : @"Auto"},
      @"1" : @{ @"distance" : @"1000",  @"label" : @"1 km."},
      @"2" : @{ @"distance" : @"5000",  @"label" : @"5 km."},
      @"3" : @{ @"distance" : @"10000",  @"label" : @"10 km."},
    };
}

- (void)expandFilterSection:(NSInteger)section {
    [self.expandedFilterSections setObject:@(true) forKey:@(section)];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)collapseFilterSection:(NSInteger)section {
    [self.expandedFilterSections setObject:@(false) forKey:@(section)];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
