//
//  ViewController.m
//  Animacao
//
//  Created by Bruna Garcia on 17/02/14.
//  Copyright (c) 2014 TokenLab. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()


@property (nonatomic) BOOL isEnableToMove;
@property (nonatomic) CGFloat lastContentOffset;
@property (nonatomic) CGFloat yMax;
@property (nonatomic) CGFloat step;

@end

@implementation ViewController

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
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = NO;
    
    self.scroll.contentSize = CGSizeMake(320, 900);
    self.scroll.delegate = self;
    self.scroll.alwaysBounceVertical = YES;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor yellowColor];
    [self.refreshControl addTarget:self action:@selector(refreshCollectionView:) forControlEvents:UIControlEventValueChanged];
    [self.scroll addSubview:self.refreshControl];

    
    self.isEnableToMove = YES;
    self.lastContentOffset = 0.0;
    
    //valor limite do self.hideView.frame.origin.y
    //Faço isso poq a headerView e a hideView possuem alturas diferentes
    self.yMax = self.headerView.frame.size.height - self.hideView.frame.size.height;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //deslocamento do scroll
    self.step = scrollView.contentOffset.y - self.lastContentOffset;
    NSLog(@"step: %f contentOffset.y: %f", self.step, self.scroll.contentOffset.y);
    
    //verifica se esta atualizando
    if(self.refreshControl.refreshing && self.scroll.contentOffset.y <= 0)
    {
        self.isEnableToMove = NO;
    }
    else
    {
        self.isEnableToMove = YES;
    }
    
    if(self.isEnableToMove)
    {
        //esconde filtro
        //step tem q ser positivo (scroll subindo)
        //a base do hideView tem que ficar alinhada a base do headerView (so desloca ate o yMax)
        // o contentOffset tem q ser positivo 
        if(self.step > 0 &&
           self.hideView.frame.origin.y > self.yMax &&
           self.scroll.contentOffset.y >= 0.0)
        {
            NSLog(@"MOSTRA");
            //verificar se  a posicao da view + step nao vai passar do limite. se passar eu defino o quanto vai subir
            if(self.hideView.frame.origin.y - self.step > self.yMax)
            {
                self.hideView.frame = CGRectMake(self.hideView.frame.origin.x,
                                                           self.hideView.frame.origin.y - self.step,
                                                           self.hideView.frame.size.width,
                                                           self.hideView.frame.size.height);
            }
            else
            {   //calcula quanto falta para chegar no yMax
                CGFloat offset = self.yMax - self.hideView.frame.origin.y;
                
                self.hideView.frame = CGRectMake(self.hideView.frame.origin.x,
                                                           self.hideView.frame.origin.y + offset,
                                                           self.hideView.frame.size.width,
                                                           self.hideView.frame.size.height);
            }
            
            //anima o scroll
            self.scroll.frame = CGRectMake(self.scroll.frame.origin.x,
                                           self.hideView.frame.origin.y + self.hideView.frame.size.height,
                                           self.scroll.frame.size.width,
                                           self.view.frame.size.height - self.headerView.frame.size.height);
            
            //nao deixa o scroll mexer enquanto esta animando o filtro
            self.scroll.contentOffset = CGPointMake(0, 0);
        }
        //mostra o filtro.
        //step negativo, a origem do filtro de filhos menor ou igual a altura da headerView (limite para mostrar o filtro) e scroll no comeco
        else if(self.step < 0 &&
                self.hideView.frame.origin.y <= self.headerView.frame.size.height &&
                self.scroll.contentOffset.y <= 0.0)
        {
            NSLog(@"ESCONDE");
            //verificar se o step nao vai passar do limite. se passar eu defino o quanto vai subir
            if(self.hideView.frame.origin.y - self.step <= self.headerView.frame.size.height)
            {
                self.hideView.frame = CGRectMake(self.hideView.frame.origin.x,
                                                           self.hideView.frame.origin.y - self.step,
                                                           self.hideView.frame.size.width,
                                                           self.hideView.frame.size.height);
            }
            else
            {   //calcula quanto falta para chegar no yMax
                CGFloat offset = self.headerView.frame.size.height - self.hideView.frame.origin.y;
                
                self.hideView.frame = CGRectMake(self.hideView.frame.origin.x,
                                                           self.hideView.frame.origin.y + offset,
                                                           self.hideView.frame.size.width,
                                                           self.hideView.frame.size.height);
            }
            
            //anima o scroll
            self.scroll.frame = CGRectMake(self.scroll.frame.origin.x,
                                           self.hideView.frame.origin.y + self.hideView.frame.size.height,
                                           self.scroll.frame.size.width,
                                           self.view.frame.size.height - self.headerView.frame.size.height);
            
        }
    }
    self.lastContentOffset = scrollView.contentOffset.y;
     
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"did end dragging");
    if(decelerate)
    {
        NSLog(@"vai chamar will begin");
        self.isEnableToMove = NO;
    }
    else
    {
        // verifica se o filtro não ficou pela metade
        //termina de esconder
        if(self.hideView.frame.origin.y < (self.headerView.frame.size.height - self.yMax)/2)
        {
            NSLog(@"DID end Dragging - esconde");
            [UIView animateWithDuration:0.2 animations:^{
                self.hideView.frame = CGRectMake(self.hideView.frame.origin.x,
                                                           self.yMax,
                                                           self.hideView.frame.size.width,
                                                           self.hideView.frame.size.height);
                
                self.scroll.frame = CGRectMake(self.scroll.frame.origin.x,
                                               self.headerView.frame.size.height,
                                               self.scroll.frame.size.width,
                                               self.view.frame.size.height - self.headerView.frame.size.height);
            }];
        }
        //mostra o filtro
        else
        {
            NSLog(@"DID end Dragging - mostra");
            [UIView animateWithDuration:0.2 animations:^{
                self.hideView.frame = CGRectMake(self.hideView.frame.origin.x,
                                                           self.headerView.frame.size.height,
                                                           self.hideView.frame.size.width,
                                                           self.hideView.frame.size.height);
                
                self.scroll.frame = CGRectMake(self.scroll.frame.origin.x,
                                               self.hideView.frame.origin.y + self.hideView.frame.size.height,
                                               self.scroll.frame.size.width,
                                               self.view.frame.size.height - self.headerView.frame.size.height - self.hideView.frame.size.height);
            }];
        }
    }

}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"will begin decelerating");
    self.isEnableToMove = NO;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"did end decelerating");
    
    // verifica se o filtro não ficou pela metade
    //termina de esconder
    if(self.hideView.frame.origin.y < (self.headerView.frame.size.height - self.yMax)/2)
    {
        NSLog(@"DID end decelerating- esconde");
        [UIView animateWithDuration:0.2 animations:^{
            self.hideView.frame = CGRectMake(self.hideView.frame.origin.x,
                                                       self.yMax,
                                                       self.hideView.frame.size.width,
                                                       self.hideView.frame.size.height);
            
            self.scroll.frame = CGRectMake(self.scroll.frame.origin.x,
                                           self.headerView.frame.size.height,
                                           self.scroll.frame.size.width,
                                           self.view.frame.size.height - self.headerView.frame.size.height);
        }];
    }
    //mostra o filtro
    else
    {
        NSLog(@"DID end decelerating - mostra");
        [UIView animateWithDuration:0.2 animations:^{
            self.hideView.frame = CGRectMake(self.hideView.frame.origin.x,
                                                       self.headerView.frame.size.height,
                                                       self.hideView.frame.size.width,
                                                       self.hideView.frame.size.height);
            
            self.scroll.frame = CGRectMake(self.scroll.frame.origin.x,
                                           self.hideView.frame.origin.y + self.hideView.frame.size.height,
                                           self.scroll.frame.size.width,
                                           self.view.frame.size.height - self.headerView.frame.size.height - self.hideView.frame.size.height);
        }];
    }
    
    self.isEnableToMove = YES;
}


- (void) refreshCollectionView: (id)sender
{
    self.isEnableToMove = NO;
    
    //da um delay para conseguir ver a animacao
    for (int i = 0; i < 100000; i++)
    {
        for (int j = 0; j < 10000; j++)
        {
            
        }
    }
    
    [self.refreshControl endRefreshing];
    
}




@end
