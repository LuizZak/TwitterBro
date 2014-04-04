//
//  Twitter.m
//  PassagemDeViews
//
//  Created by ARTHUR HENRIQUE VIEIRA DE OLIVEIRA on 27/03/14.
//  Copyright (c) 2014 FILIPE KUNIOSHI. All rights reserved.
//

#import "TBTwitter.h"

@implementation TBTwitter

+ (TBTwitter *) twitter
{
    static TBTwitter *twitter = nil;
    if (!twitter)
    {
        twitter = [[super allocWithZone:nil] init];
    }
    return twitter;
}

+ (id)allocWithZone: (struct _NSZone *)zone
{
    return [self twitter];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        auth = NO;
        observers = [[NSMutableArray alloc] init];
        internalRequestId = 0;
        
        self.dataRecebida = [NSArray array];
        self.accountStore = [[ACAccountStore alloc] init];
        self.accountType = [[self accountStore] accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        self.loadedAccounts = [self.accountStore accountsWithAccountType:self.accountType];
        
        [self.accountStore requestAccessToAccountsWithType:self.accountType options:nil completion:^(BOOL granted, NSError *error)
         {
             if (granted == YES)
             {
                 self.loadedAccounts = [[self accountStore] accountsWithAccountType:[self accountType]];
                 
                 if(self.loadedAccounts.count == 0)
                 {
                     // Notifica os observers do erro
                     @synchronized(observers)
                     {
                         // Notifica os observers
                         for(id<TBTwitterObserver> observer in observers)
                         {
                             if([observer respondsToSelector:@selector(twitterDidFailAuthehticateUser:)])
                             {
                                 [observer twitterDidFailAuthehticateUser:error];
                             }
                         }
                     }
                     
                     return;
                 }
                 
                 self.twitterAccount = self.loadedAccounts[0];
                 
                 // Notifica os observers
                 @synchronized(observers)
                 {
                     // Notifica os observers
                     for(id<TBTwitterObserver> observer in observers)
                     {
                         if([observer respondsToSelector:@selector(twitterDidAuthenticateUser:)])
                         {
                             [observer twitterDidAuthenticateUser:self.twitterAccount];
                         }
                         if([observer respondsToSelector:@selector(twitterDidBecomeReady)])
                         {
                             [observer twitterDidBecomeReady];
                         }
                     }
                 }
                 
                 auth = YES;
                 
                 // Carrega a conta do perfil do usuário atual
                 NSString *contaDoUsuario = self.twitterAccount.username;
                 
                 NSURL *url = [[NSURL alloc] initWithString:@"https://api.twitter.com/1.1/users/show.json"];
                 
                 NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:contaDoUsuario, @"screen_name", nil];
                 
                 SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters: params];
                 
                 [request setAccount:self.twitterAccount];
                 
                 [request performRequestWithHandler:
                  ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                      if (responseData) {
                          NSDictionary *user =
                          [NSJSONSerialization JSONObjectWithData:responseData
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                          
                          self.twitterProfile = [TBJSONParser generateAccountForJSON:user];
                      }
                  }];
             }
         }];
    }
    
    return self;
}

- (BOOL)authenticated
{
    return auth;
}

// Adiciona um observer para receber eventos assícronos da classe singleton
- (void)addObserver:(id<TBTwitterObserver>)observer
{
    @synchronized(observers)
    {
        [observers addObject:observer];
        
        // Chama o método de ready caso a API já esteja pronta
        if(auth)
        {
            if([observer respondsToSelector:@selector(twitterDidBecomeReady)])
            {
                [observer twitterDidBecomeReady];
            }
        }
    }
}

// Remove um observer desta classe para ele parar de receber eventos assícronos desta classe
- (void)removeObserver:(id<TBTwitterObserver>)observer
{
    @synchronized(observers)
    {
        [observers removeObject:observer];
    }
}

- (void)tweet:(UIViewController*)view text:(NSString*)text image:(UIImage *)image
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        if(image != nil)
        {
            [tweetSheet addImage:image];
        }
        
        [tweetSheet setInitialText:text];
        [view presentViewController:tweetSheet animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                            message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

// Posta um tweet com a imagem provida como anexo
- (long)postTweet:(NSString*)text image:(UIImage*)image callback:(void (^)(long, TBTweet*))callbackBlock
{
    long rid = internalRequestId++;
    
    NSURL *url = [[NSURL alloc] initWithString:@"https://api.twitter.com/1.1/statuses/update_with_media.json"];
    
    // Transforma a mídia em base64 e coloca na requisição
    /*NSString *base64 = [self base64Image:image];
    
    [params setObject:base64 forKey:@"media[]"];*/

    SLRequest *pegarUsuario = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:url parameters:nil];
    
    [pegarUsuario addMultipartData:[text dataUsingEncoding:NSUTF8StringEncoding] withName:@"status" type:@"multipart/form-data" filename:nil];
    //[pegarUsuario addMultiPartData:[@"I just found the secret level!" dataUsingEncoding:NSUTF8StringEncoding] withName:@"status" type:@"multipart/form-data"];
    
    [pegarUsuario setAccount:self.twitterAccount];
    
    [pegarUsuario performRequestWithHandler:
     ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
         if (responseData)
         {
             NSDictionary *responseJson =
             [NSJSONSerialization JSONObjectWithData:responseData
                                             options:NSJSONReadingAllowFragments
                                               error:nil];
             
             // Verifica se house algum erro durante a requisição
             NSArray *arrayDeErros = [responseJson objectForKey:@"errors"];
             
             id erroa = arrayDeErros[0];
             
             if(arrayDeErros != nil)
             {
                 // Chama o callback
                 if(callbackBlock != nil)
                 {
                     callbackBlock(rid, nil);
                 }
                 
                 @synchronized(observers)
                 {
                     // Notifica os observers
                     for(id<TBTwitterObserver> observer in observers)
                     {
                         if([observer respondsToSelector:@selector(twitterDidReceiveError:errors:)])
                         {
                             [observer twitterDidReceiveError:rid errors:arrayDeErros];
                         }
                     }
                 }
                 
                 return;
             }
             
             TBTweet *tweet = [TBJSONParser generateTweetForJSON:responseJson];
             
             // Chama o callback
             if(callbackBlock != nil)
             {
                 callbackBlock(rid, tweet);
             }
             
             @synchronized(observers)
             {
                 // Notifica os observers
                 for(id<TBTwitterObserver> observer in observers)
                 {
                     if([observer respondsToSelector:@selector(twitterDidPostTweet:requestId:)])
                     {
                         [observer twitterDidPostTweet:tweet requestId:rid];
                     }
                 }
             }
         }
     }];
    
    return rid;
}

// Busca um usuário por user name (o '@') e notifica os observers quando achar
- (long)searchUserByName:(NSString*)userName callback:(void (^)(long, TBAccount*))callbackBlock;
{
    long rid = internalRequestId++;
    
    NSString *contaDoUsuario = userName;
    
    NSURL *url = [[NSURL alloc] initWithString:@"https://api.twitter.com/1.1/users/show.json"];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:contaDoUsuario, @"screen_name",nil];
    
    SLRequest *pegarUsuario = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters: params];
    
    [pegarUsuario setAccount:self.twitterAccount];
    
    [pegarUsuario performRequestWithHandler:
     ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
         if (responseData)
         {
             NSDictionary *responseJson =
             [NSJSONSerialization JSONObjectWithData:responseData
                                             options:NSJSONReadingAllowFragments
                                               error:nil];
             
             // Verifica se house algum erro durante a requisição
             NSArray *arrayDeErros = [responseJson objectForKey:@"errors"];
             
             if(arrayDeErros != nil)
             {
                 // Chama o callback
                 if(callbackBlock != nil)
                 {
                     callbackBlock(rid, nil);
                 }
                 
                 @synchronized(observers)
                 {
                     // Notifica os observers
                     for(id<TBTwitterObserver> observer in observers)
                     {
                         if([observer respondsToSelector:@selector(twitterDidReceiveError:errors:)])
                         {
                             [observer twitterDidReceiveError:rid errors:arrayDeErros];
                         }
                     }
                 }
                 
                 return;
             }
             
             TBAccount *account = [TBJSONParser generateAccountForJSON:responseJson];
             
             // Chama o callback
             if(callbackBlock != nil)
             {
                 callbackBlock(rid, account);
             }
             
             @synchronized(observers)
             {
                 // Notifica os observers
                 for(id<TBTwitterObserver> observer in observers)
                 {
                     if([observer respondsToSelector:@selector(twitterDidReceiveUser:requestId:error:)])
                     {
                         [observer twitterDidReceiveUser:account requestId:rid error:error];
                     }
                 }
             }
         }
     }];
    
    return rid;
}

// Busca um usuário por user name (o '@') e notifica os observers quando achar
- (long)searchUserByID:(unsigned long long)userID callback:(void (^)(long, TBAccount*))callbackBlock
{
    long rid = internalRequestId++;
    
    NSURL *url = [[NSURL alloc] initWithString:@"https://api.twitter.com/1.1/users/show.json"];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedLongLong:userID], @"user_id",nil];
    
    SLRequest *pegarUsuario = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters: params];
    
    [pegarUsuario setAccount:self.twitterAccount];
    
    [pegarUsuario performRequestWithHandler:
     ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
         if (responseData)
         {
             NSDictionary *responseJson =
             [NSJSONSerialization JSONObjectWithData:responseData
                                             options:NSJSONReadingAllowFragments
                                               error:nil];
             
             // Verifica se house algum erro durante a requisição
             NSArray *arrayDeErros = [responseJson objectForKey:@"errors"];
             
             if(arrayDeErros != nil)
             {
                 // Chama o callback
                 if(callbackBlock != nil)
                 {
                     callbackBlock(rid, nil);
                 }
                 
                 @synchronized(observers)
                 {
                     // Notifica os observers
                     for(id<TBTwitterObserver> observer in observers)
                     {
                         if([observer respondsToSelector:@selector(twitterDidReceiveError:errors:)])
                         {
                             [observer twitterDidReceiveError:rid errors:arrayDeErros];
                         }
                     }
                 }
                 
                 return;
             }
             
             TBAccount *account = [TBJSONParser generateAccountForJSON:responseJson];
             
             // Chama o callback
             if(callbackBlock != nil)
             {
                 callbackBlock(rid, account);
             }
             
             @synchronized(observers)
             {
                 // Notifica os observers
                 for(id<TBTwitterObserver> observer in observers)
                 {
                     if([observer respondsToSelector:@selector(twitterDidReceiveUser:requestId:error:)])
                     {
                         [observer twitterDidReceiveUser:account requestId:rid error:error];
                     }
                 }
             }
         }
     }];
    
    return rid;
}

// Busca um tweet por id e notifica os observers quando achar
- (long)buscarTweetPorID:(unsigned long long)tweetId callback:(void (^)(long, TBTweet*))callbackBlock
{
    long rid = internalRequestId++;
    
    NSURL *url = [[NSURL alloc] initWithString:@"https://api.twitter.com/1.1/statuses/show.json"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSString stringWithFormat:@"%lli", tweetId] forKey:@"id"];
    
    SLRequest *pegarTweet = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters: params];
    
    [pegarTweet setAccount:self.twitterAccount];
    
    [pegarTweet performRequestWithHandler:
     ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
         if (responseData)
         {
             NSDictionary *responseJson =
             [NSJSONSerialization JSONObjectWithData:responseData
                                             options:NSJSONReadingAllowFragments
                                               error:nil];
             
             // Verifica se house algum erro durante a requisição
             NSArray *arrayDeErros = [responseJson objectForKey:@"errors"];
             
             if(arrayDeErros != nil)
             {
                 // Chama o callback
                 if(callbackBlock != nil)
                 {
                     callbackBlock(rid, nil);
                 }
                 
                 @synchronized(observers)
                 {
                     // Notifica os observers
                     for(id<TBTwitterObserver> observer in observers)
                     {
                         if([observer respondsToSelector:@selector(twitterDidReceiveError:errors:)])
                         {
                             [observer twitterDidReceiveError:rid errors:arrayDeErros];
                         }
                     }
                 }
                 
                 return;
             }
             
             TBTweet *tbTweet = [TBJSONParser generateTweetForJSON:responseJson];
             
             // Chama o callback
             if(callbackBlock != nil)
             {
                 callbackBlock(rid, tbTweet);
             }
             
             @synchronized(observers)
             {
                 // Notifica os observers
                 for(id<TBTwitterObserver> observer in observers)
                 {
                     if([observer respondsToSelector:@selector(twitterDidReceiveUser:requestId:error:)])
                     {
                         [observer twitterDidReceiveTweet:tbTweet requestId:rid error:error];
                     }
                 }
             }
         }
     }];
    
    return rid;
}

// Busca tweets que contém as hashtags dispostas na array especificada
- (long)searchTweetsWithTerms:(NSArray*)termsArray maxResultCount:(int)maxResults callback:(void (^)(long, NSMutableArray*))callbackBlock
{
    long rid = internalRequestId++;
    
    // Compoe as hashtags
    NSString *composto = [termsArray[0] description];
    
    for(int i = 1; i < termsArray.count; i++)
    {
        composto = [NSString stringWithFormat:@"%@ %@", composto, [termsArray[i] description]];
    }
    
    // Cria o request
    NSURL *url = [[NSURL alloc] initWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:composto forKey:@"q"];
    [params setObject:[NSString stringWithFormat:@"%i", maxResults] forKey:@"count"];
    
    SLRequest *pegarTweet = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters: params];
    
    [pegarTweet setAccount:self.twitterAccount];
    
    [pegarTweet performRequestWithHandler:
     ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
         dispatch_async(dispatch_get_main_queue(), ^{
         if (responseData)
         {
             NSDictionary *responseJson =
             [NSJSONSerialization JSONObjectWithData:responseData
                                             options:NSJSONReadingAllowFragments
                                               error:nil];
             
             // Verifica se house algum erro durante a requisição
             NSArray *arrayDeErros = [responseJson objectForKey:@"errors"];
             
             if(arrayDeErros != nil)
             {
                 // Chama o callback
                 if(callbackBlock != nil)
                 {
                     callbackBlock(rid, nil);
                 }
                 
                 @synchronized(observers)
                 {
                     // Notifica os observers
                     for(id<TBTwitterObserver> observer in observers)
                     {
                         if([observer respondsToSelector:@selector(twitterDidReceiveError:errors:)])
                         {
                             [observer twitterDidReceiveError:rid errors:arrayDeErros];
                         }
                     }
                 }
                 
                 return;
             }
             
             // Varre os resultados e monta uma array de tweets achados
             NSArray *statuses = [responseJson objectForKey:@"statuses"];
             NSMutableArray *tweets = [[NSMutableArray alloc] init];
             for(NSDictionary *dict in statuses)
             {
                 [tweets addObject:[TBJSONParser generateTweetForJSON:dict]];
             }
             
             // Chama o callback
             if(callbackBlock != nil)
             {
                 callbackBlock(rid, tweets);
             }
             
             // Responde aos observers
             @synchronized(observers)
             {
                 // Notifica os observers
                 for(id<TBTwitterObserver> observer in observers)
                 {
                     if([observer respondsToSelector:@selector(twitterDidReceiveMultipleTweets:requestId:error:)])
                     {
                         [observer twitterDidReceiveMultipleTweets:tweets requestId:rid error:error];
                     }
                 }
             }
         }});
     }];
    
    return rid;
}

// Método helper que transforma uma imagem em base64
- (NSString*)base64Image:(UIImage*)image
{
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

@end
